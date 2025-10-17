import 'package:rema_1001/map/map.dart';

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
