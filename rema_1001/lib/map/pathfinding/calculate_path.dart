import 'package:flutter/material.dart';
import 'package:rema_1001/map/pathfinding/pathfinding_aisle.dart';

/// Grid dimensions (problem statement)
const int _gridSize = 64;

/// Main entry: compute the route visiting all target aisles from any one of
/// their access points (fastest choice per aisle), avoiding all aisle boxes.
List<Waypoint> calculatePath({
  required List<PathfindingAisle> aisles,
  required Offset start,
  required Offset end,
}) {
  // Normalize to integer grid coordinates (tile centers modeled as integer cells)
  final startC = _pt(start);
  final endC = _pt(end);

  // Build blocked grid (true if inside any aisle)
  final blocked = List.generate(
    _gridSize,
    (_) => List<bool>.filled(_gridSize, false),
  );
  for (final a in aisles) {
    final r = _rect(a);
    for (int y = r.top; y <= r.bottom; y++) {
      for (int x = r.left; x <= r.right; x++) {
        if (_inBounds(x, y)) blocked[y][x] = true;
      }
    }
  }

  // Compute access points for each aisle (index aligned with aisles list)
  final List<List<_Cell>> accessPointsByAisle = List.generate(
    aisles.length,
    (_) => [],
  );
  for (int i = 0; i < aisles.length; i++) {
    final aps = calculateAccessPointForAisle(
      aisle: aisles[i],
    ).map(_pt).where((c) => _inBounds(c.x, c.y) && !blocked[c.y][c.x]).toList();
    accessPointsByAisle[i] = aps;
  }

  // Collect per-target (isTarget==true) groups of candidate nodes.
  final targetIndices = <int>[];
  for (int i = 0; i < aisles.length; i++) {
    if (aisles[i].isTarget) targetIndices.add(i);
  }

  // If there are target aisles, ensure each has at least one access point.
  for (final tIdx in targetIndices) {
    if (accessPointsByAisle[tIdx].isEmpty) {
      // No legal access point -> route impossible under constraints.
      return []; // or throw StateError('No access point for aisle $tIdx');
    }
  }

  // Build node registry:
  // node 0 = start, nodes 1..K = every access point with (aisleIdx, localIdx), last node = end
  final List<_Cell> nodes = [];
  final List<_NodeMeta> metas = [];

  nodes.add(startC);
  metas.add(_NodeMeta(type: _NodeType.start));

  // Map aisle -> node indices of its APs (for marking visited when reaching any AP)
  final Map<int, List<int>> aisleToNodeIdxs = {};

  for (int aIdx = 0; aIdx < aisles.length; aIdx++) {
    final aps = accessPointsByAisle[aIdx];
    aisleToNodeIdxs[aIdx] = [];
    for (int k = 0; k < aps.length; k++) {
      nodes.add(aps[k]);
      metas.add(_NodeMeta(type: _NodeType.accessPoint, aisleIndex: aIdx));
      aisleToNodeIdxs[aIdx]!.add(nodes.length - 1);
    }
  }

  nodes.add(endC);
  metas.add(_NodeMeta(type: _NodeType.end));
  final int startNode = 0;
  final int endNode = nodes.length - 1;

  // Precompute shortest paths (grid A*) between all pairs we might traverse.
  // We need distances between: start <-> every AP, AP <-> AP, AP <-> end, start <-> end.
  final int nNodes = nodes.length;
  final List<List<int?>> dist = List.generate(
    nNodes,
    (_) => List<int?>.filled(nNodes, null),
  );
  final Map<_Pair, List<_Cell>> pathCache = {};

  List<_Cell> pathBetween(int a, int b) {
    final key = _Pair(a, b);
    if (pathCache.containsKey(key)) return pathCache[key]!;
    final p = _aStar(blocked, nodes[a], nodes[b]);
    pathCache[key] = p; // may be empty if unreachable
    return p;
  }

  int? distBetween(int a, int b) {
    if (dist[a][b] != null) return dist[a][b];
    final p = pathBetween(a, b);
    final d = p.isEmpty ? null : (p.length - 1);
    dist[a][b] = d;
    dist[b][a] = d;
    return d;
  }

  // Dijkstra on state space: (visitedMask over target aisles, currentNode)
  // Visiting any AP of a target aisle sets its bit.
  final int T = targetIndices.length;
  final Map<int, int> aisleToBit = {
    for (int i = 0; i < T; i++) targetIndices[i]: i,
  };

  int maskAfter(int node, int mask) {
    final m = metas[node];
    if (m.type == _NodeType.accessPoint && m.aisleIndex != null) {
      final bit = aisleToBit[m.aisleIndex!];
      if (bit != null) return mask | (1 << bit);
    }
    return mask;
  }

  final fullMask = (T == 0) ? 0 : ((1 << T) - 1);

  // Priority queue: (cost, mask, node)
  final _PQ pq = _PQ();
  final Map<_State, int> best = {};
  final Map<_State, _State?> parent = {};
  final Map<_State, int?> parentEdgeTo = {}; // next node to reconstruct
  final startState = _State(0, startNode);

  pq.push(0, startState);
  best[startState] = 0;
  parent[startState] = null;
  parentEdgeTo[startState] = null;

  _State? goalState;

  while (pq.isNotEmpty) {
    final top = pq.pop();
    final cost = top.cost;
    final state = top.state;

    // If this isn't the up-to-date best, skip.
    final known = best[state];
    if (known != null && cost > known) continue;

    final visited = state.mask;
    final cur = state.node;

    if (visited == fullMask) {
      // We can go to end; pushing an explicit edge to end allows reconstruction.
      final d = distBetween(cur, endNode);
      if (d != null) {
        final total = cost + d;
        final endState = _State(visited, endNode);
        if (best[endState] == null || total < best[endState]!) {
          best[endState] = total;
          parent[endState] = state;
          parentEdgeTo[endState] = endNode;
          pq.push(total, endState);
        }
      }
    }

    // Transitions: to any access point (of any target not yet visited) and also to end if no targets.
    for (int next = 1; next < nNodes - 1; next++) {
      final meta = metas[next];
      if (meta.type != _NodeType.accessPoint) continue;

      // If this AP belongs to a non-target aisle, it's allowed but doesn’t change mask.
      // If it belongs to a target aisle already visited, you can still traverse through,
      // but usually unnecessary; we allow it to keep correctness.
      final d = distBetween(cur, next);
      if (d == null) continue;

      final newMask = maskAfter(next, visited);
      // Optional small pruning: if this AP is for a target already visited, we still allow,
      // but the PQ + best map will prune suboptimal loops.

      final nextState = _State(newMask, next);
      final newCost = cost + d;
      if (best[nextState] == null || newCost < best[nextState]!) {
        best[nextState] = newCost;
        parent[nextState] = state;
        parentEdgeTo[nextState] = next;
        pq.push(newCost, nextState);
      }
    }

    // If no targets, we still need a direct path start -> end.
    if (T == 0 && cur == startNode) {
      final d = distBetween(cur, endNode);
      if (d != null) {
        final endState = _State(0, endNode);
        final total = cost + d;
        if (best[endState] == null || total < best[endState]!) {
          best[endState] = total;
          parent[endState] = state;
          parentEdgeTo[endState] = endNode;
          pq.push(total, endState);
        }
      }
    }
  }

  // Pick the best finished state: (fullMask, endNode)
  final finish = _State(fullMask, endNode);
  if (best[finish] == null) {
    return []; // No feasible route
  }
  goalState = finish;

  // Reconstruct high-level node sequence
  final List<int> nodeSequence = [];
  _State? cur = goalState;
  while (cur != null) {
    final edgeTo = parentEdgeTo[cur];
    if (edgeTo != null) nodeSequence.add(edgeTo);
    cur = parent[cur];
  }
  nodeSequence.add(startNode);

  // Use a reversed copy:
  final seq = nodeSequence.reversed.toList();

  // Build full step-by-step path by concatenating precomputed pair paths
  final List<_Cell> full = [];
  for (int i = 0; i + 1 < seq.length; i++) {
    final a = seq[i];
    final b = seq[i + 1];
    final seg = pathBetween(a, b);
    if (seg.isEmpty) return [];
    if (full.isNotEmpty) {
      full.addAll(seg.skip(1));
    } else {
      full.addAll(seg);
    }
  }

  // Convert to Waypoints; mark waypoints that are exactly an access point cell.
  // Map grid cell -> target aisle index (if AP).
  final Map<_Cell, int> cellToTarget = {};
  for (final tIdx in targetIndices) {
    for (final nodeIdx in aisleToNodeIdxs[tIdx] ?? const []) {
      cellToTarget[nodes[nodeIdx]] = tIdx;
    }
  }

  return full
      .map(
        (c) => Waypoint(
          position: Offset(c.x.toDouble(), c.y.toDouble()),
          targetAisleIndex: cellToTarget[c],
        ),
      )
      .toList();
}

/// Compute access points for one aisle per the rules.
///
/// For each side (top, bottom, left, right), we consider positions along the
/// side where placing an access point exactly two tiles *perpendicular outward*
/// would land on free space (and the two tiles between the side and the point
/// are also free). Among these, we find the longest contiguous run ("unobstructed
/// area") for each side. We then choose the side(s) with the maximum such run,
/// and place an access point at the *midpoint* of that run, offset outward by 2.
List<Offset> calculateAccessPointForAisle({required PathfindingAisle aisle}) {
  final r = _rect(aisle);

  // Build a quick occupancy test for "another aisle" placements.
  bool isBlocked(int x, int y) {
    if (!_inBounds(x, y)) return true;
    // Blocked if inside this aisle OR any other aisle? The rule says:
    // "A side is unobstructed if no other aisles are in the position of where
    //  the access point would be placed." It allows being adjacent to itself.
    // Here we will only check against other aisles by passing them separately.
    return false; // Placeholder; real check happens in the closure below.
  }

  // We need to know other aisles to check "no other aisles at AP position".
  // We don’t have them here, so the caller version above did that filter.
  // Inside this function, we compute *candidate* APs relative to this aisle,
  // and the top-level calculatePath() filters against global obstacles.
  //
  // To make this function useful standalone, we'll ensure we do not place the
  // AP inside this aisle and that the two in-between cells lie outside this aisle.
  bool outsideThisAisle(int x, int y) {
    return x < r.left || x > r.right || y < r.top || y > r.bottom;
  }

  List<Offset> out = [];

  // Helper to scan a side and return: (bestRunStart, bestRunEnd, outward dx,dy)
  _SideResult scanHorizontalSide(int ySide, int outwardDy, int xFrom, int xTo) {
    int bestLen = 0, bestS = -1, bestE = -1;
    int s = -1;

    for (int x = xFrom; x <= xTo; x++) {
      final y1 = ySide + outwardDy ~/ 2; // first step outward (±1)
      final y2 = ySide + outwardDy; // second step outward (±2)
      final ok = outsideThisAisle(x, y1) && outsideThisAisle(x, y2);
      if (ok) {
        if (s == -1) s = x;
      } else {
        if (s != -1) {
          final e = x - 1;
          final len = e - s + 1;
          if (len > bestLen) {
            bestLen = len;
            bestS = s;
            bestE = e;
          }
          s = -1;
        }
      }
    }
    if (s != -1) {
      final e = xTo;
      final len = e - s + 1;
      if (len > bestLen) {
        bestLen = len;
        bestS = s;
        bestE = e;
      }
    }
    return _SideResult(bestLen, bestS, bestE, 0, outwardDy);
  }

  _SideResult scanVerticalSide(int xSide, int outwardDx, int yFrom, int yTo) {
    int bestLen = 0, bestS = -1, bestE = -1;
    int s = -1;

    for (int y = yFrom; y <= yTo; y++) {
      final x1 = xSide + outwardDx ~/ 2; // first step outward (±1)
      final x2 = xSide + outwardDx; // second step outward (±2)
      final ok = outsideThisAisle(x1, y) && outsideThisAisle(x2, y);
      if (ok) {
        if (s == -1) s = y;
      } else {
        if (s != -1) {
          final e = y - 1;
          final len = e - s + 1;
          if (len > bestLen) {
            bestLen = len;
            bestS = s;
            bestE = e;
          }
          s = -1;
        }
      }
    }
    if (s != -1) {
      final e = yTo;
      final len = e - s + 1;
      if (len > bestLen) {
        bestLen = len;
        bestS = s;
        bestE = e;
      }
    }
    return _SideResult(bestLen, bestS, bestE, outwardDx, 0);
  }

  final topRes = scanHorizontalSide(r.top, -2, r.left, r.right);
  final bottomRes = scanHorizontalSide(r.bottom, 2, r.left, r.right);
  final leftRes = scanVerticalSide(r.left, -2, r.top, r.bottom);
  final rightRes = scanVerticalSide(r.right, 2, r.top, r.bottom);

  final results = {
    'top': topRes,
    'bottom': bottomRes,
    'left': leftRes,
    'right': rightRes,
  };

  final maxLen = results.values.fold<int>(0, (m, s) => s.len > m ? s.len : m);
  if (maxLen == 0) {
    return out; // No unobstructed side segment found
  }

  void addMidpoint(_SideResult res, String side) {
    final mid = (res.s + res.e) ~/ 2;
    if (side == 'top' || side == 'bottom') {
      final x = mid;
      final y = (side == 'top') ? r.top + res.dy : r.bottom + res.dy;
      if (_inBounds(x, y)) out.add(Offset(x.toDouble(), y.toDouble()));
    } else {
      final y = mid;
      final x = (side == 'left') ? r.left + res.dx : r.right + res.dx;
      if (_inBounds(x, y)) out.add(Offset(x.toDouble(), y.toDouble()));
    }
  }

  results.forEach((side, res) {
    if (res.len == maxLen && res.len > 0) {
      addMidpoint(res, side);
    }
  });

  return out;
}

/* -------------------------- Helpers & internals -------------------------- */

class _IntRect {
  final int left, top, right, bottom;
  const _IntRect(this.left, this.top, this.right, this.bottom);
}

_IntRect _rect(PathfindingAisle a) {
  final x0 = a.topLeft.dx.toInt();
  final y0 = a.topLeft.dy.toInt();
  final w = a.width;
  final h = a.height;
  return _IntRect(x0, y0, x0 + w - 1, y0 + h - 1);
}

bool _inBounds(int x, int y) =>
    x >= 0 && y >= 0 && x < _gridSize && y < _gridSize;

class _Cell {
  final int x, y;
  const _Cell(this.x, this.y);
  @override
  bool operator ==(Object o) => o is _Cell && o.x == x && o.y == y;
  @override
  int get hashCode => x * 131 + y;
}

_Cell _pt(Offset o) => _Cell(o.dx.toInt(), o.dy.toInt());

class _Pair {
  final int a, b;
  const _Pair(this.a, this.b);
  @override
  bool operator ==(Object o) => o is _Pair && a == o.a && b == o.b;
  @override
  int get hashCode => a * 1000003 ^ b;
}

enum _NodeType { start, accessPoint, end }

class _NodeMeta {
  final _NodeType type;
  final int? aisleIndex;
  const _NodeMeta({required this.type, this.aisleIndex});
}

class _SideResult {
  final int len;
  final int s;
  final int e;
  final int dx;
  final int dy;
  const _SideResult(this.len, this.s, this.e, this.dx, this.dy);
}

/// Simple A* on 4-neighbour grid with Manhattan heuristic
List<_Cell> _aStar(List<List<bool>> blocked, _Cell start, _Cell goal) {
  if (start == goal) return [start];
  if (!_inBounds(start.x, start.y) || !_inBounds(goal.x, goal.y)) return [];

  int h(_Cell c) => (c.x - goal.x).abs() + (c.y - goal.y).abs();

  final open = _PQ2(); // min-heap by f = g + h
  final g = <_Cell, int>{};
  final parent = <_Cell, _Cell?>{};

  g[start] = 0;
  parent[start] = null;
  open.push(_AStarNode(start, h(start)));

  final dirs = const [_Cell(1, 0), _Cell(-1, 0), _Cell(0, 1), _Cell(0, -1)];

  while (open.isNotEmpty) {
    final current = open.pop().cell;
    if (current == goal) {
      // reconstruct
      final path = <_Cell>[];
      _Cell? c = current;
      while (c != null) {
        path.add(c);
        c = parent[c];
      }
      return path.reversed.toList();
    }
    final gCur = g[current]!;
    for (final d in dirs) {
      final nx = current.x + d.x;
      final ny = current.y + d.y;
      if (!_inBounds(nx, ny) || blocked[ny][nx]) continue;
      final nb = _Cell(nx, ny);
      final cand = gCur + 1;
      if (cand < (g[nb] ?? 1 << 30)) {
        g[nb] = cand;
        parent[nb] = current;
        open.push(_AStarNode(nb, cand + h(nb)));
      }
    }
  }
  return []; // unreachable
}

/* --------- Tiny priority queues (no external packages needed) --------- */

class _PQItem {
  final int cost;
  final _State state;
  _PQItem(this.cost, this.state);
}

class _PQ {
  final List<_PQItem> _heap = [];
  bool get isNotEmpty => _heap.isNotEmpty;
  void push(int cost, _State st) {
    _heap.add(_PQItem(cost, st));
    _siftUp(_heap.length - 1);
  }

  _PQItem pop() {
    final res = _heap.first;
    final last = _heap.removeLast();
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _siftDown(0);
    }
    return res;
  }

  void _siftUp(int i) {
    while (i > 0) {
      final p = (i - 1) >> 1;
      if (_heap[p].cost <= _heap[i].cost) break;
      final tmp = _heap[p];
      _heap[p] = _heap[i];
      _heap[i] = tmp;
      i = p;
    }
  }

  void _siftDown(int i) {
    final n = _heap.length;
    while (true) {
      int l = i * 2 + 1, r = l + 1, m = i;
      if (l < n && _heap[l].cost < _heap[m].cost) m = l;
      if (r < n && _heap[r].cost < _heap[m].cost) m = r;
      if (m == i) break;
      final tmp = _heap[m];
      _heap[m] = _heap[i];
      _heap[i] = tmp;
      i = m;
    }
  }
}

class _State {
  final int mask;
  final int node;
  const _State(this.mask, this.node);
  @override
  bool operator ==(Object o) => o is _State && o.mask == mask && o.node == node;
  @override
  int get hashCode => mask * 131071 ^ node;
}

class _AStarNode {
  final _Cell cell;
  final int f;
  _AStarNode(this.cell, this.f);
}

class _PQ2 {
  final List<_AStarNode> _heap = [];
  bool get isNotEmpty => _heap.isNotEmpty;
  void push(_AStarNode n) {
    _heap.add(n);
    _up(_heap.length - 1);
  }

  _AStarNode pop() {
    final res = _heap.first;
    final last = _heap.removeLast();
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _down(0);
    }
    return res;
  }

  void _up(int i) {
    while (i > 0) {
      final p = (i - 1) >> 1;
      if (_heap[p].f <= _heap[i].f) break;
      final t = _heap[p];
      _heap[p] = _heap[i];
      _heap[i] = t;
      i = p;
    }
  }

  void _down(int i) {
    final n = _heap.length;
    while (true) {
      int l = i * 2 + 1, r = l + 1, m = i;
      if (l < n && _heap[l].f < _heap[m].f) m = l;
      if (r < n && _heap[r].f < _heap[m].f) m = r;
      if (m == i) break;
      final t = _heap[m];
      _heap[m] = _heap[i];
      _heap[i] = t;
      i = m;
    }
  }
}

void main() {
  print("lol");
}
