import 'package:flutter/widgets.dart';
import 'package:rema_1001/map/model.dart';

bool _aislesOverlap(Aisle a1, Aisle a2) {
  // Calculate bounds
  final x1 = a1.topLeft.dx;
  final y1 = a1.topLeft.dy;
  final r1 = x1 + a1.width;
  final b1 = y1 + a1.height;

  final x2 = a2.topLeft.dx;
  final y2 = a2.topLeft.dy;
  final r2 = x2 + a2.width;
  final b2 = y2 + a2.height;

  // Check if rectangles overlap or touch
  return x1 < r2 && r1 > x2 && y1 < b2 && b1 > y2;
}

List<List<int>> groupOverlappingAisles(List<Aisle> aisles) {
  final groups = <List<int>>[];
  final assigned = List<bool>.filled(aisles.length, false);

  for (int i = 0; i < aisles.length; i++) {
    if (assigned[i]) continue;

    final group = <int>[i];
    assigned[i] = true;

    // Keep checking for overlaps until no new ones are found
    bool foundNew = true;
    while (foundNew) {
      foundNew = false;
      for (int j = 0; j < aisles.length; j++) {
        if (assigned[j]) continue;

        // Check if aisle j overlaps with any aisle in the current group
        for (final groupIdx in group) {
          if (_aislesOverlap(aisles[groupIdx], aisles[j]) &&
              aisles[groupIdx].status == aisles[j].status) {
            group.add(j);
            assigned[j] = true;
            foundNew = true;
            break;
          }
        }
      }
    }

    groups.add(group);
  }

  return groups;
}

/// Check if aisle1 is completely inside aisle2
bool isAisleInside(Aisle inner, Aisle outer) {
  final innerLeft = inner.topLeft.dx;
  final innerTop = inner.topLeft.dy;
  final innerRight = innerLeft + inner.width;
  final innerBottom = innerTop + inner.height;

  final outerLeft = outer.topLeft.dx;
  final outerTop = outer.topLeft.dy;
  final outerRight = outerLeft + outer.width;
  final outerBottom = outerTop + outer.height;

  return innerLeft >= outerLeft &&
      innerTop >= outerTop &&
      innerRight <= outerRight &&
      innerBottom <= outerBottom &&
      // Make sure it's actually inside, not the same
      !(innerLeft == outerLeft &&
          innerTop == outerTop &&
          innerRight == outerRight &&
          innerBottom == outerBottom);
}

/// Result of getAisleRRect containing the RRect and the alignment axis
typedef AisleRRectResult = ({RRect rrect, Axis? alignmentAxis});

/// Get custom border radius RRect for an aisle based on which edges are exposed
/// If the aisle is inside a parent, corners that touch internal edges will have no radius
/// Returns a record with the RRect and the alignment axis (horizontal if top/bottom aligned, vertical if left/right aligned)
AisleRRectResult getAisleRRect(
  Aisle aisle,
  double scaleX,
  double scaleY,
  double borderRadius,
  Aisle? parent,
) {
  final rect = Rect.fromLTWH(
    aisle.topLeft.dx * scaleX,
    aisle.topLeft.dy * scaleY,
    aisle.width * scaleX,
    aisle.height * scaleY,
  );

  if (parent == null) {
    // No parent, use uniform border radius
    return (
      rrect: RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      alignmentAxis: null,
    );
  }

  // Calculate edges
  final aisleLeft = aisle.topLeft.dx;
  final aisleTop = aisle.topLeft.dy;
  final aisleRight = aisleLeft + aisle.width;
  final aisleBottom = aisleTop + aisle.height;

  final parentLeft = parent.topLeft.dx;
  final parentTop = parent.topLeft.dy;
  final parentRight = parentLeft + parent.width;
  final parentBottom = parentTop + parent.height;

  // Tolerance for edge detection (consider edges within this distance as "touching")
  final tolerance = 0.1;

  // Check which edges align with parent edges (are flush/overlapping)
  final topAligned = (aisleTop - parentTop).abs() < tolerance;
  final bottomAligned = (aisleBottom - parentBottom).abs() < tolerance;
  final leftAligned = (aisleLeft - parentLeft).abs() < tolerance;
  final rightAligned = (aisleRight - parentRight).abs() < tolerance;

  // Determine alignment axis
  Axis? alignmentAxis;
  if (topAligned || bottomAligned) {
    alignmentAxis = Axis.horizontal;
  } else if (leftAligned || rightAligned) {
    alignmentAxis = Axis.vertical;
  }

  // Corners should have NO radius if either adjacent edge is aligned (flush)
  // Corners should have radius if both adjacent edges are inside (not aligned)
  final radius = Radius.circular(borderRadius);
  final noRadius = Radius.zero;

  return (
    rrect: RRect.fromRectAndCorners(
      rect,
      topLeft: (topAligned || leftAligned) ? noRadius : radius,
      topRight: (topAligned || rightAligned) ? noRadius : radius,
      bottomLeft: (bottomAligned || leftAligned) ? noRadius : radius,
      bottomRight: (bottomAligned || rightAligned) ? noRadius : radius,
    ),
    alignmentAxis: alignmentAxis,
  );
}
