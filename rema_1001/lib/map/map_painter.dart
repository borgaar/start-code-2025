import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:rema_1001/map/model.dart' as map_model;
import 'package:rema_1001/map/pathfinding/pathfinding_aisle.dart';
import 'package:rema_1001/map/utils.dart';

final dimension = 64;
final double aisleBorderRadiusBase = 1;
final double backgroundBorderRadiusBase = 4;
final softShadowOffsetBase = Offset(0.4, 0.8);
final backgroundColor = Color(0xff434343);
final backgroundPaint = Paint()..color = backgroundColor;

Offset getSoftShadowOffset(double scaleX, double scaleY) {
  return Offset(
    softShadowOffsetBase.dx * scaleX,
    softShadowOffsetBase.dy * scaleY,
  );
}

final class MapPainter implements CustomPainter {
  final map_model.MapModel map;
  final List<Waypoint>? path;
  final int currentPathStep;

  MapPainter({required this.map, required this.path, this.currentPathStep = 0});

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
    final scaleX = size.width / dimension;
    final scaleY = size.height / dimension;

    // Create the full path
    final fullPath = Path();
    fullPath.moveTo(path[0].position.dx * scaleX, path[0].position.dy * scaleY);

    for (int i = 1; i < path.length; i++) {
      fullPath.lineTo(
        path[i].position.dx * scaleX,
        path[i].position.dy * scaleY,
      );
    }

    // Paint the full path in gray
    final grayPathPaint = Paint()
      ..color = const Color(0xFF5A5A5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fullPath, grayPathPaint);

    // Paint the active path (up to current step) in white
    if (currentPathStep > 0 && currentPathStep < path.length) {
      final activePath = Path();
      activePath.moveTo(
        path[0].position.dx * scaleX,
        path[0].position.dy * scaleY,
      );

      for (int i = 1; i <= currentPathStep && i < path.length; i++) {
        activePath.lineTo(
          path[i].position.dx * scaleX,
          path[i].position.dy * scaleY,
        );
      }

      final whitePathPaint = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(activePath, whitePathPaint);
    }

    // Draw a dot at the current position
    if (currentPathStep >= 0 && currentPathStep < path.length) {
      final currentPosition = Offset(
        path[currentPathStep].position.dx * scaleX,
        path[currentPathStep].position.dy * scaleY,
      );

      final dotPaint = Paint()..color = const Color(0xFFFFFFFF);
      canvas.drawCircle(currentPosition, 6, dotPaint);
    }

    // Draw arrow at the end of the path
    _paintArrow(canvas, size, path);
  }

  void _paintArrow(Canvas canvas, Size size, List<Waypoint> path) {
    if (path.length < 2) return;

    final scaleX = size.width / dimension;
    final scaleY = size.height / dimension;

    // Get the last two points to determine arrow direction
    final lastPoint = Offset(
      path[path.length - 1].position.dx * scaleX,
      path[path.length - 1].position.dy * scaleY,
    );
    final secondLastPoint = Offset(
      path[path.length - 2].position.dx * scaleX,
      path[path.length - 2].position.dy * scaleY,
    );

    // Calculate direction vector
    final direction = lastPoint - secondLastPoint;
    final angle = direction.direction;

    // Arrow dimensions
    final arrowLength = 12.0;

    // Create arrow path
    final arrowPath = Path();
    arrowPath.moveTo(lastPoint.dx, lastPoint.dy);
    arrowPath.lineTo(
      lastPoint.dx - arrowLength * math.cos(angle - math.pi / 6),
      lastPoint.dy - arrowLength * math.sin(angle - math.pi / 6),
    );
    arrowPath.moveTo(lastPoint.dx, lastPoint.dy);
    arrowPath.lineTo(
      lastPoint.dx - arrowLength * math.cos(angle + math.pi / 6),
      lastPoint.dy - arrowLength * math.sin(angle + math.pi / 6),
    );

    final arrowPaint = Paint()
      ..color = const Color(0xFF5A5A5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(arrowPath, arrowPaint);
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
        rect.shift(getSoftShadowOffset(scaleX, scaleY)),
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
      combinedPath.shift(getSoftShadowOffset(scaleX, scaleY)),
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
