import 'package:flutter/widgets.dart';
import 'package:rema_1001/map/model.dart' as map_model;
import 'package:rema_1001/map/pathfinding/pathfinding_aisle.dart';
import 'package:rema_1001/map/utils.dart';

final dimension = 64;
final double aisleBorderRadiusBase = 2;
final double backgroundBorderRadiusBase = 4;
final softShadowOffset = Offset(8, 10);
final backgroundColor = Color(0xff434343);
final backgroundPaint = Paint()..color = backgroundColor;

final class MapPainter implements CustomPainter {
  final map_model.MapModel map;
  final List<Waypoint>? path;

  MapPainter({required this.map, required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintIsles(canvas, size, map);
    if (path != null && path!.isNotEmpty) {
      _paintPath(canvas, size, path!);
    }
  }

  @override
  void addListener(VoidCallback listener) {}

  @override
  bool? hitTest(Offset position) {
    return null;
  }

  @override
  void removeListener(VoidCallback listener) {}

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _paintPath(Canvas canvas, Size size, List<Waypoint> path) {
    // Paint a dot for each point in the path (in red)
    final paint = Paint()..color = const Color(0xFFFF0000);
    final scaleX = size.width / dimension;
    final scaleY = size.height / dimension;

    final drawPath = Path();
    drawPath.moveTo(path[0].position.dx * scaleX, path[0].position.dy * scaleY);

    for (final waypoint in path) {
      final position = Offset(
        waypoint.position.dx * scaleX,
        waypoint.position.dy * scaleY,
      );
      drawPath.lineTo(
        waypoint.position.dx * scaleX,
        waypoint.position.dy * scaleY,
      );
      canvas.drawCircle(position, 4, paint);
    }

    final pathPaint = Paint()
      ..color = const Color(0x88FF0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(drawPath, pathPaint);
  }

  void _paintIsle(Canvas canvas, Size size, map_model.Aisle aisle) {
    // Scale factors to convert map coordinates to canvas size
    final scaleX = size.width / dimension;
    final scaleY = size.height / dimension;
    final aisleBorderRadius = scaleX * aisleBorderRadiusBase;

    // Check if this aisle is inside another aisle with a DIFFERENT status
    map_model.Aisle? parentAisle;
    for (final other in map.aisles) {
      if (other != aisle &&
          other.status != aisle.status &&
          isAisleInside(aisle, other)) {
        parentAisle = other;
        break;
      }
    }

    // Get RRect with selective corner radii
    final result = getAisleRRect(
      aisle,
      scaleX,
      scaleY,
      aisleBorderRadius,
      parentAisle,
    );
    final hardShadowRect = result.rrect;
    final shouldHaveShadow = result.alignmentAxis != Axis.vertical;
    final rect = hardShadowRect.outerRect;

    // Create shifted versions of the RRect
    RRect? softShadowRRect;
    if (parentAisle == null) {
      softShadowRRect = RRect.fromRectAndCorners(
        rect.shift(softShadowOffset),
        topLeft: hardShadowRect.tlRadius,
        topRight: hardShadowRect.trRadius,
        bottomLeft: hardShadowRect.blRadius,
        bottomRight: hardShadowRect.brRadius,
      );
    }

    final aisleRect = RRect.fromRectAndCorners(
      rect.shift(Offset(0, -aisle.hardShadowHeight)),
      topLeft: hardShadowRect.tlRadius,
      topRight: hardShadowRect.trRadius,
      bottomLeft: hardShadowRect.blRadius,
      bottomRight: hardShadowRect.brRadius,
    );

    if (softShadowRRect != null) {
      canvas.drawRRect(softShadowRRect, aisle.softShadowPaint);
    }

    // Obstruction
    if (shouldHaveShadow) {
      canvas.drawRRect(hardShadowRect, aisle.hardShadowPaint);
    }
    canvas.drawRRect(aisleRect, aisle.paint);

    canvas.drawRRect(aisleRect, aisle.glowPaint);
  }

  void _paintAisleGroup(
    Canvas canvas,
    Size size,
    List<map_model.Aisle> aisles,
  ) {
    final scaleX = size.width / dimension;
    final scaleY = size.height / dimension;
    final aisleBorderRadius = scaleX * aisleBorderRadiusBase;

    // Combine all rectangles into a single path
    Path combinedPath = Path();
    for (final aisle in aisles) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          aisle.topLeft.dx * scaleX,
          aisle.topLeft.dy * scaleY,
          aisle.width * scaleX,
          aisle.height * scaleY,
        ),
        Radius.circular(aisleBorderRadius),
      );
      combinedPath = Path.combine(
        PathOperation.union,
        combinedPath,
        Path()..addRRect(rect),
      );
    }

    // Get a sample aisle for status (assume all in group have same status)
    final sampleAisle = aisles.first;

    // Obstruction shadow
    canvas.drawPath(
      combinedPath.shift(softShadowOffset),
      sampleAisle.softShadowPaint,
    );

    canvas.drawPath(combinedPath, sampleAisle.hardShadowPaint);
    // Obstruction
    canvas.drawPath(
      combinedPath.shift(Offset(0, -sampleAisle.hardShadowHeight)),
      sampleAisle.paint,
    );

    // Glow
    canvas.drawPath(
      combinedPath.shift(Offset(0, -sampleAisle.hardShadowHeight)),
      sampleAisle.glowPaint,
    );
  }

  void _paintIsles(Canvas canvas, Size size, map_model.MapModel map) {
    final groups = groupOverlappingAisles(map.aisles);

    final List<map_model.Aisle> isles = [];

    for (final group in groups) {
      if (group.length == 1) {
        // Single aisle, use the regular painting method
        isles.add(map.aisles[group[0]]);
      } else {
        // Multiple overlapping aisles, paint as a combined group
        final groupAisles = group.map((i) => map.aisles[i]).toList();
        _paintAisleGroup(canvas, size, groupAisles);
      }
    }

    for (final aisle in isles) {
      _paintIsle(canvas, size, aisle);
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    final backgroundBorderRadius = Radius.circular(
      size.width / dimension * backgroundBorderRadiusBase,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width, size.height, backgroundBorderRadius),
      backgroundPaint,
    );
  }
}
