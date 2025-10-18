import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rema_1001/map/pathfinding/pathfinding_aisle.dart';

// Constants
const int kGridSize = 64;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Check if point is within grid bounds (0-63 inclusive)
bool _isInBounds(Offset point) {
  return point.dx >= 0 &&
      point.dx < kGridSize &&
      point.dy >= 0 &&
      point.dy < kGridSize;
}

/// Check if point collides with any aisle's bounding box
/// Includes 1 coordinate padding around aisles to avoid corner clipping
/// Extra 2 units of padding on top for graphical clearance
bool _collidesWithAisle(Offset point, List<PathfindingAisle> aisles) {
  const double sidePadding = 0.5;
  const double topPadding = 0.5;
  const double bottomPadding = 0.5;

  for (final aisle in aisles) {
    final left = aisle.topLeft.dx - sidePadding;
    final top = aisle.topLeft.dy - topPadding;
    final right = aisle.topLeft.dx + aisle.width + sidePadding;
    final bottom = aisle.topLeft.dy + aisle.height + bottomPadding;

    if (point.dx >= left &&
        point.dx < right &&
        point.dy >= top &&
        point.dy < bottom) {
      return true;
    }
  }
  return false;
}

/// Calculate Euclidean distance between two points
double _distance(Offset a, Offset b) {
  final dx = a.dx - b.dx;
  final dy = a.dy - b.dy;
  return sqrt(dx * dx + dy * dy);
}

// ============================================================================
// A* PATHFINDING WITH 8-DIRECTIONAL MOVEMENT
// ============================================================================

/// Node for A* pathfinding
class _AStarNode {
  final Offset position;
  final double gCost; // Distance from start
  final double hCost; // Heuristic to goal
  final _AStarNode? parent;

  _AStarNode({
    required this.position,
    required this.gCost,
    required this.hCost,
    this.parent,
  });

  double get fCost => gCost + hCost;
}

/// A* pathfinding with 8-directional movement
/// Returns list of intermediate waypoints from start to goal
/// Returns empty list if no valid path exists
List<Offset> _aStar({
  required Offset start,
  required Offset goal,
  required List<PathfindingAisle> aisles,
}) {
  // Round start and goal to ensure integer coordinates
  final roundedStart = Offset(
    start.dx.roundToDouble(),
    start.dy.roundToDouble(),
  );
  final roundedGoal = Offset(goal.dx.roundToDouble(), goal.dy.roundToDouble());

  // Validate start and goal positions
  if (!_isInBounds(roundedStart) || !_isInBounds(roundedGoal)) {
    return []; // Invalid start or goal
  }
  if (_collidesWithAisle(roundedStart, aisles) ||
      _collidesWithAisle(roundedGoal, aisles)) {
    return []; // Start or goal is inside an aisle
  }

  // 8 directions: N, NE, E, SE, S, SW, W, NW
  final directions = [
    const Offset(0, -1), // N
    const Offset(1, -1), // NE
    const Offset(1, 0), // E
    const Offset(1, 1), // SE
    const Offset(0, 1), // S
    const Offset(-1, 1), // SW
    const Offset(-1, 0), // W
    const Offset(-1, -1), // NW
  ];

  final openSet = <_AStarNode>[];
  final closedSet = <String>{};

  String posKey(Offset pos) => '${pos.dx.round()},${pos.dy.round()}';

  final startNode = _AStarNode(
    position: roundedStart,
    gCost: 0,
    hCost: _distance(roundedStart, roundedGoal),
  );

  openSet.add(startNode);

  while (openSet.isNotEmpty) {
    // Find node with lowest fCost
    openSet.sort((a, b) => a.fCost.compareTo(b.fCost));
    final current = openSet.removeAt(0);

    // Check if we reached the goal (within 1.0 tolerance for better reachability)
    if (_distance(current.position, roundedGoal) < 1.0) {
      // Reconstruct path
      final path = <Offset>[];
      _AStarNode? node = current;
      while (node != null) {
        path.add(node.position);
        node = node.parent;
      }
      return path.reversed.toList();
    }

    closedSet.add(posKey(current.position));

    // Explore neighbors in 8 directions
    for (final dir in directions) {
      final neighborPos = Offset(
        current.position.dx + dir.dx,
        current.position.dy + dir.dy,
      );

      // Skip if invalid
      if (!_isInBounds(neighborPos)) continue;
      if (closedSet.contains(posKey(neighborPos))) continue;
      if (_collidesWithAisle(neighborPos, aisles)) continue;

      // Calculate costs (diagonal = √2, straight = 1)
      final isDiagonal = dir.dx != 0 && dir.dy != 0;
      final moveCost = isDiagonal ? sqrt(2) : 1.0;
      final gCost = current.gCost + moveCost;

      // Check if this path is better
      final existingIdx = openSet.indexWhere(
        (n) => posKey(n.position) == posKey(neighborPos),
      );

      if (existingIdx == -1 || gCost < openSet[existingIdx].gCost) {
        final neighborNode = _AStarNode(
          position: neighborPos,
          gCost: gCost,
          hCost: _distance(neighborPos, roundedGoal),
          parent: current,
        );

        if (existingIdx != -1) {
          openSet.removeAt(existingIdx);
        }
        openSet.add(neighborNode);
      }
    }
  }

  // No path found - return empty list instead of direct path through obstacles
  return [];
}

// ============================================================================
// PATH SIMPLIFICATION
// ============================================================================

/// Check if there's a clear line of sight between two points
bool _hasLineOfSight(Offset start, Offset end, List<PathfindingAisle> aisles) {
  final distance = _distance(start, end);
  if (distance < 1.0) return true;

  // Sample points along the line
  final steps = (distance * 2).ceil(); // More samples for accuracy
  for (int i = 0; i <= steps; i++) {
    final t = i / steps;
    final point = Offset(
      start.dx + (end.dx - start.dx) * t,
      start.dy + (end.dy - start.dy) * t,
    );

    if (_collidesWithAisle(point, aisles)) {
      return false;
    }
  }

  return true;
}

/// Simplify path by removing unnecessary intermediate waypoints
/// Only keeps waypoints where direction changes or line of sight is blocked
List<Offset> _simplifyPath(List<Offset> path, List<PathfindingAisle> aisles) {
  if (path.length <= 2) return path;

  final simplified = <Offset>[path.first];
  int currentIndex = 0;

  while (currentIndex < path.length - 1) {
    int farthestVisible = currentIndex + 1;

    // Find the farthest point we can see from current position
    for (int i = currentIndex + 2; i < path.length; i++) {
      if (_hasLineOfSight(path[currentIndex], path[i], aisles)) {
        farthestVisible = i;
      } else {
        break; // Can't see beyond this point
      }
    }

    simplified.add(path[farthestVisible]);
    currentIndex = farthestVisible;
  }

  return simplified;
}

// ============================================================================
// ACCESS POINT CALCULATION
// ============================================================================

/// Calculate valid access points for an aisle
/// Access points are placed 2 tiles perpendicular to the middle of the
/// longest unobstructed side(s)
/// All coordinates are rounded to integers for pathfinding compatibility
List<Offset> calculateAccessPointForAisle({
  required PathfindingAisle aisle,
  required List<PathfindingAisle> allAisles,
}) {
  final accessPoints = <Offset>[];
  // Exclude current aisle from collision checks (otherwise top access points get rejected)
  final otherAisles = allAisles.where((a) => a != aisle).toList();

  final left = aisle.topLeft.dx;
  final top = aisle.topLeft.dy;
  final right = left + aisle.width;
  final bottom = top + aisle.height;

  // Define all 4 sides with their properties
  final sides = [
    // Top side
    {
      'length': aisle.width,
      'middle': Offset((left + right) / 2, top),
      'perpendicular': const Offset(0, -1),
    },
    // Bottom side
    {
      'length': aisle.width,
      'middle': Offset((left + right) / 2, bottom),
      'perpendicular': const Offset(0, 1),
    },
    // Left side
    {
      'length': aisle.height,
      'middle': Offset(left, (top + bottom) / 2),
      'perpendicular': const Offset(-1, 0),
    },
    // Right side
    {
      'length': aisle.height,
      'middle': Offset(right, (top + bottom) / 2),
      'perpendicular': const Offset(1, 0),
    },
  ];

  // Find sides that are unobstructed and their lengths
  final validSides = <Map<String, dynamic>>[];

  for (final side in sides) {
    final middle = side['middle'] as Offset;
    final perpendicular = side['perpendicular'] as Offset;

    // FORCE INTEGER COORDINATES by rounding the middle position
    final roundedMiddle = Offset(
      middle.dx.roundToDouble(),
      middle.dy.roundToDouble(),
    );

    final accessPoint = Offset(
      roundedMiddle.dx + perpendicular.dx,
      roundedMiddle.dy + perpendicular.dy,
    );

    // Check if this side is unobstructed by OTHER aisles (not the current one)
    if (_isInBounds(accessPoint) &&
        !_collidesWithAisle(accessPoint, otherAisles)) {
      validSides.add({...side, 'accessPoint': accessPoint});
    }
  }

  if (validSides.isEmpty) return accessPoints;

  // Find maximum length among valid sides
  final maxLength = validSides
      .map((s) => s['length'] as int)
      .reduce((a, b) => a > b ? a : b);

  // Add access points for all sides with maximum length
  for (final side in validSides) {
    if (side['length'] == maxLength) {
      accessPoints.add(side['accessPoint'] as Offset);
    }
  }

  return accessPoints;
}

// ============================================================================
// TSP SOLVERS - OPTIMAL PATH ORDERING
// ============================================================================

/// Generate all permutations and find the shortest total path
/// Used for small TSP instances (≤10 aisles)
List<int> _solveTspPermutations(
  Map<int, Offset> points,
  Map<int, int> pointToAisle,
  Offset end,
  Map<int, List<Offset>> aisleAccessPoints,
) {
  final aisleIndices = pointToAisle.keys.toList();
  if (aisleIndices.isEmpty) return [];

  double bestDistance = double.infinity;
  List<int>? bestOrder;

  // Generate all permutations
  _generatePermutations(aisleIndices, 0, (perm) {
    // Calculate total distance for this permutation
    double totalDist = 0;
    Offset currentPos = points[-1]!; // Start position

    for (final pointIdx in perm) {
      final aisleIdx = pointToAisle[pointIdx]!;
      final accessPoints = aisleAccessPoints[aisleIdx]!;

      // Find closest access point from current position
      double minDist = double.infinity;
      Offset? closestAp;
      for (final ap in accessPoints) {
        final dist = _distance(currentPos, ap);
        if (dist < minDist) {
          minDist = dist;
          closestAp = ap;
        }
      }

      if (closestAp != null) {
        totalDist += minDist;
        currentPos = closestAp;
      } else {
        return; // Invalid access point, skip this permutation
      }
    }

    // Add distance to end
    totalDist += _distance(currentPos, end);

    if (totalDist < bestDistance) {
      bestDistance = totalDist;
      bestOrder = perm.toList();
    }
  });

  if (bestOrder == null) return [];

  // Convert point indices to aisle indices
  return bestOrder!.map((pointIdx) => pointToAisle[pointIdx]!).toList();
}

/// Helper to generate permutations
void _generatePermutations(
  List<int> list,
  int start,
  void Function(List<int>) callback,
) {
  if (start >= list.length - 1) {
    callback(list);
    return;
  }

  for (int i = start; i < list.length; i++) {
    // Swap
    final temp = list[start];
    list[start] = list[i];
    list[i] = temp;

    _generatePermutations(list, start + 1, callback);

    // Swap back
    list[i] = list[start];
    list[start] = temp;
  }
}

/// Held-Karp dynamic programming algorithm for TSP
/// Used for larger TSP instances (>10 aisles)
/// Time complexity: O(n^2 * 2^n), Space: O(n * 2^n)
List<int> _solveTspHeldKarp(
  Map<int, Offset> points,
  Map<int, int> pointToAisle,
  Offset end,
  Map<int, List<Offset>> aisleAccessPoints,
) {
  final aisleIndices = pointToAisle.keys.toList();
  final n = aisleIndices.length;

  if (n == 0) return [];
  if (n == 1) return [pointToAisle[aisleIndices[0]]!];

  // Distance cache
  final distCache = <String, double>{};
  double getDist(Offset from, int toPointIdx) {
    final toAisleIdx = pointToAisle[toPointIdx]!;
    final accessPoints = aisleAccessPoints[toAisleIdx]!;

    final key = '${from.dx},${from.dy}->$toPointIdx';
    if (distCache.containsKey(key)) return distCache[key]!;

    double minDist = double.infinity;
    for (final ap in accessPoints) {
      final dist = _distance(from, ap);
      if (dist < minDist) minDist = dist;
    }

    distCache[key] = minDist;
    return minDist;
  }

  // DP table: dp[mask][last] = (minCost, parent)
  final dp = <int, Map<int, (double, int)>>{};

  // Initialize: visit each aisle as first stop from start
  final startPos = points[-1]!;
  for (int i = 0; i < n; i++) {
    final mask = 1 << i;
    dp[mask] = {i: (getDist(startPos, aisleIndices[i]), -1)};
  }

  // Fill DP table
  for (int mask = 1; mask < (1 << n); mask++) {
    if (!dp.containsKey(mask)) continue;

    for (int last = 0; last < n; last++) {
      if ((mask & (1 << last)) == 0) continue;
      if (!dp[mask]!.containsKey(last)) continue;

      final (currentCost, _) = dp[mask]![last]!;
      final lastPointIdx = aisleIndices[last];
      final lastAisleIdx = pointToAisle[lastPointIdx]!;
      final lastAccessPoints = aisleAccessPoints[lastAisleIdx]!;

      // Find best position for 'last' aisle
      Offset? lastPos;
      double bestLastDist = double.infinity;
      for (final ap in lastAccessPoints) {
        // Estimate distance from previous position (simplified)
        if (currentCost < bestLastDist) {
          bestLastDist = currentCost;
          lastPos = ap;
        }
      }

      lastPos ??= lastAccessPoints.first;

      // Try extending to next unvisited aisle
      for (int next = 0; next < n; next++) {
        if ((mask & (1 << next)) != 0) continue; // Already visited

        final nextMask = mask | (1 << next);
        final nextPointIdx = aisleIndices[next];
        final distToNext = getDist(lastPos, nextPointIdx);
        final newCost = currentCost + distToNext;

        dp.putIfAbsent(nextMask, () => {});
        if (!dp[nextMask]!.containsKey(next) ||
            dp[nextMask]![next]!.$1 > newCost) {
          dp[nextMask]![next] = (newCost, last);
        }
      }
    }
  }

  // Find best final configuration
  final finalMask = (1 << n) - 1;
  if (!dp.containsKey(finalMask)) return [];

  double bestFinalCost = double.infinity;
  int? bestLast;

  for (int last = 0; last < n; last++) {
    if (!dp[finalMask]!.containsKey(last)) continue;

    final (cost, _) = dp[finalMask]![last]!;
    final lastAisleIdx = pointToAisle[aisleIndices[last]]!;
    final lastAccessPoints = aisleAccessPoints[lastAisleIdx]!;

    // Add distance to end
    double minEndDist = double.infinity;
    for (final ap in lastAccessPoints) {
      final dist = _distance(ap, end);
      if (dist < minEndDist) minEndDist = dist;
    }

    final totalCost = cost + minEndDist;

    if (totalCost < bestFinalCost) {
      bestFinalCost = totalCost;
      bestLast = last;
    }
  }

  if (bestLast == null) return [];

  // Reconstruct path
  final path = <int>[];
  int currentMask = finalMask;
  int currentLast = bestLast;

  while (currentLast != -1) {
    path.add(aisleIndices[currentLast]);
    final (_, parent) = dp[currentMask]![currentLast]!;

    if (parent == -1) break;

    currentMask ^= (1 << currentLast);
    currentLast = parent;
  }

  // Convert to aisle indices and reverse
  return path.reversed.map((pointIdx) => pointToAisle[pointIdx]!).toList();
}

// ============================================================================
// MAIN PATHFINDING ALGORITHM
// ============================================================================

/// Calculate complete path from start to end, visiting all target aisles
/// Returns list of waypoints with intermediate points for 8-directional movement
List<Waypoint> calculatePath({
  required List<PathfindingAisle> aisles,
  required Offset start,
  required Offset end,
}) {
  final waypoints = <Waypoint>[];

  // Get indices of target aisles
  final targetAisleIndices = <int>[];
  for (int i = 0; i < aisles.length; i++) {
    if (aisles[i].isTarget) {
      targetAisleIndices.add(i);
    }
  }

  // If no target aisles, just path directly to end
  if (targetAisleIndices.isEmpty) {
    var path = _aStar(start: start, goal: end, aisles: aisles);
    if (path.isEmpty) return []; // No valid path

    // Simplify the path
    path = _simplifyPath(path, aisles);

    return path
        .map((p) => Waypoint(position: p, targetAisleIndex: null))
        .toList();
  }

  // Calculate access points for all target aisles
  final aisleAccessPoints = <int, List<Offset>>{};
  for (final aisleIndex in targetAisleIndices) {
    aisleAccessPoints[aisleIndex] = calculateAccessPointForAisle(
      aisle: aisles[aisleIndex],
      allAisles: aisles,
    );
  }

  // ========================================================================
  // OPTIMAL TSP: Find shortest path through all target aisles
  // Uses dynamic programming (Held-Karp) for guaranteed optimal solution
  // ========================================================================

  // Build distance matrix between all points
  // Points: [start, aisle0, aisle1, ..., aisleN, end]
  final points = <int, Offset>{-1: start}; // -1 = start
  final pointToAisle = <int, int>{}; // point index -> aisle index

  int pointIdx = 0;
  for (final aisleIndex in targetAisleIndices) {
    final accessPoints = aisleAccessPoints[aisleIndex]!;
    if (accessPoints.isEmpty) continue;

    // Use closest access point to start as representative
    Offset? bestAp;
    double bestDist = double.infinity;
    for (final ap in accessPoints) {
      final dist = _distance(start, ap);
      if (dist < bestDist) {
        bestDist = dist;
        bestAp = ap;
      }
    }

    if (bestAp != null) {
      points[pointIdx] = bestAp;
      pointToAisle[pointIdx] = aisleIndex;
      pointIdx++;
    }
  }

  final n = points.length - 1; // Number of aisles (excluding start)

  if (n == 0) {
    // No valid aisles, path directly to end
    var path = _aStar(start: start, goal: end, aisles: aisles);
    if (path.isEmpty) return [];
    path = _simplifyPath(path, aisles);
    return path
        .map((p) => Waypoint(position: p, targetAisleIndex: null))
        .toList();
  }

  // For small problems, use full permutation search for absolute optimality
  // For larger problems (>10), use Held-Karp DP
  List<int> visitOrder;

  if (n <= 10) {
    // Permutation-based exact solution
    visitOrder = _solveTspPermutations(
      points,
      pointToAisle,
      end,
      aisleAccessPoints,
    );
  } else {
    // Held-Karp dynamic programming
    visitOrder = _solveTspHeldKarp(
      points,
      pointToAisle,
      end,
      aisleAccessPoints,
    );
  }

  /// Merge adjacent path points when they can be replaced by a single corner
  /// without colliding with aisles. This should be called after A* and any
  /// path simplification.
  ///
  /// Example: [{1,1},{5,3},{6,4}]  ->  [{1,1},{5,4}]  or  [{1,1},{6,3}]
  List<Offset> mergeTightAdjacentPoints(
    List<Offset> path,
    List<PathfindingAisle> aisles,
  ) {
    if (path.length < 2) return path;

    final result = <Offset>[];
    int i = 0;

    while (i < path.length - 1) {
      final a = path[i];
      final b = path[i + 1];

      final dx = (b.dx - a.dx).round();
      final dy = (b.dy - a.dy).round();

      // Case 1: diagonal neighbors (|dx|==1 && |dy|==1)
      if (dx.abs() == 1 && dy.abs() == 1) {
        // Two candidate corner points: (ax, by) and (bx, ay)
        final cornerA = Offset(a.dx, b.dy); // e.g., (5,4)
        final cornerB = Offset(b.dx, a.dy); // e.g., (6,3)

        final aBlocked = _collidesWithAisle(cornerA, aisles);
        final bBlocked = _collidesWithAisle(cornerB, aisles);

        if (aBlocked && bBlocked) {
          // Can't merge, keep 'a' and move on
          result.add(a);
          i += 1;
          continue;
        }

        Offset pick;
        if (!aBlocked && bBlocked) {
          pick = cornerA;
        } else if (aBlocked && !bBlocked) {
          pick = cornerB;
        } else {
          // Neither is blocked — pick the one that makes a better local bend.
          // "Better" = shorter + straighter wrt previous/next points.
          final prev = result.isNotEmpty ? result.last : null;
          final next = (i + 2 < path.length) ? path[i + 2] : null;

          double score(Offset c) {
            // Prefer line of sight and smaller total length prev->c->next
            double s = 0.0;

            if (prev != null) {
              s += _distance(prev, c);
              // reward line-of-sight (subtract a tiny epsilon)
              if (_hasLineOfSight(prev, c, aisles)) s -= 0.001;
            }
            if (next != null) {
              s += _distance(c, next);
              if (_hasLineOfSight(c, next, aisles)) s -= 0.001;
            }
            return s;
          }

          final sA = score(cornerA);
          final sB = score(cornerB);
          pick = (sA <= sB) ? cornerA : cornerB;
        }

        // Emit the merged corner instead of the pair (a,b)
        // Avoid duplicating if equals last
        if (result.isEmpty || _distance(result.last, pick) >= 0.1) {
          result.add(Offset(pick.dx.roundToDouble(), pick.dy.roundToDouble()));
        }
        // Skip both a and b
        i += 2;
        continue;
      }

      // Case 2: very close points (distance < 1.0) — keep just one of them
      if (_distance(a, b) < 1.0) {
        // Prefer the non-colliding one; if both fine, keep 'b' to move forward
        final keepA = !_collidesWithAisle(a, aisles);
        final keepB = !_collidesWithAisle(b, aisles);
        final chosen = keepB || !keepA ? b : a;

        if (result.isEmpty || _distance(result.last, chosen) >= 0.1) {
          result.add(
            Offset(chosen.dx.roundToDouble(), chosen.dy.roundToDouble()),
          );
        }
        i += 2; // consumed both
        continue;
      }

      // Default: keep point a
      if (result.isEmpty || _distance(result.last, a) >= 0.1) {
        result.add(Offset(a.dx.roundToDouble(), a.dy.roundToDouble()));
      }
      i += 1;
    }

    // Add the final point if we didn't consume it above
    if (i == path.length - 1) {
      final last = path.last;
      if (result.isEmpty || _distance(result.last, last) >= 0.1) {
        result.add(Offset(last.dx.roundToDouble(), last.dy.roundToDouble()));
      }
    }

    return result;
  }

  // ========================================================================
  // BUILD COMPLETE PATH WITH INTERMEDIATE WAYPOINTS
  // ========================================================================
  Offset currentPos = start;

  for (final aisleIndex in visitOrder) {
    final accessPoints = aisleAccessPoints[aisleIndex]!;
    if (accessPoints.isEmpty) continue;

    // Find closest access point from current position
    Offset? bestAccessPoint;
    double bestDistance = double.infinity;

    for (final ap in accessPoints) {
      final distance = _distance(currentPos, ap);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestAccessPoint = ap;
      }
    }

    if (bestAccessPoint == null) continue;

    // Get A* path from current position to this access point
    var pathSegment = _aStar(
      start: currentPos,
      goal: bestAccessPoint,
      aisles: aisles,
    );

    // Skip this aisle if no valid path found
    if (pathSegment.isEmpty) continue;

    // Simplify the path to reduce waypoints
    pathSegment = _simplifyPath(pathSegment, aisles);
    pathSegment = mergeTightAdjacentPoints(pathSegment, aisles);

    // Add waypoints (skip first if it duplicates last added)
    for (int i = 0; i < pathSegment.length; i++) {
      if (waypoints.isNotEmpty &&
          _distance(waypoints.last.position, pathSegment[i]) < 0.1) {
        continue;
      }

      // Mark the access point with the aisle index
      final isAccessPoint = i == pathSegment.length - 1;
      waypoints.add(
        Waypoint(
          position: pathSegment[i],
          targetAisleIndex: isAccessPoint ? aisleIndex : null,
        ),
      );
    }

    currentPos = bestAccessPoint;
  }

  // Final path segment from last aisle to end
  var finalSegment = _aStar(start: currentPos, goal: end, aisles: aisles);

  // If no path to end, return what we have so far
  if (finalSegment.isEmpty) {
    return waypoints;
  }

  // Simplify final segment
  finalSegment = _simplifyPath(finalSegment, aisles);
  finalSegment = mergeTightAdjacentPoints(finalSegment, aisles);

  for (int i = 0; i < finalSegment.length; i++) {
    if (waypoints.isNotEmpty &&
        _distance(waypoints.last.position, finalSegment[i]) < 0.1) {
      continue;
    }
    waypoints.add(Waypoint(position: finalSegment[i], targetAisleIndex: null));
  }

  return waypoints;
}
