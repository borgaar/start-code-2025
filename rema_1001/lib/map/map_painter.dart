import 'package:flutter/widgets.dart';
import 'package:rema_1001/map/map.dart' as map_model;
import 'package:rema_1001/map/utils.dart';

final dimension = 64;
final double hardShadowHeight = 12;
final double aisleBorderRadius = 9;

final backgroundBorderRadius = Radius.circular(16);
final backgroundPaint = Paint()..color = const Color(0xff434343);
final borderPaint = Paint()
  ..color = const Color(0xff2C2C2C)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 30
  ..strokeCap = StrokeCap.round;

final aisleGreyPaint = Paint()..color = const Color(0xFF636363);
final aisleGreyShadowPaint = Paint()..color = const Color(0xFF636363);

final aisleBlackPaint = Paint()..color = const Color(0xff2C2C2C);
final aisleBlackShadowPaint = Paint()..color = const Color(0x5C000000);

final aisleWhitePaint = Paint()..color = const Color(0xffffffff);
final aisleWhiteShadowPaint = Paint()..color = const Color(0xff9A9A9A);

final softShadowPaint = Paint()
  ..color = const Color(0x52000000)
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
final softShadowOffset = Offset(4, 12);

final class MapPainter implements CustomPainter {
  final map_model.Map map;

  MapPainter({required this.map});

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintIsles(canvas, size, map);
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

  void _paintIsle(Canvas canvas, Size size, map_model.Aisle aisle) {
    // Scale factors to convert map coordinates to canvas size
    final scaleX = size.width / dimension;
    final scaleY = size.height / dimension;

    final rect = Rect.fromLTWH(
      aisle.topLeft.dx * scaleX,
      aisle.topLeft.dy * scaleY,
      aisle.width * scaleX,
      aisle.height * scaleY,
    );

    switch (aisle.status) {
      case map_model.AisleStatus.black:
        // Obstruction shadow
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(aisleBorderRadius)),
          aisleBlackShadowPaint,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.shift(softShadowOffset),
            Radius.circular(aisleBorderRadius),
          ),
          softShadowPaint,
        );

        // Obstruction
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.shift(Offset(0, -hardShadowHeight)),
            Radius.circular(aisleBorderRadius),
          ),
          aisleBlackPaint,
        );
        break;

      case map_model.AisleStatus.grey:
        // Hard shadow
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(aisleBorderRadius)),
          aisleGreyShadowPaint,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.shift(softShadowOffset),
            Radius.circular(aisleBorderRadius),
          ),
          softShadowPaint,
        );

        // Aisle
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.shift(Offset(0, -hardShadowHeight)),
            Radius.circular(aisleBorderRadius),
          ),
          aisleGreyPaint,
        );

        break;
      case map_model.AisleStatus.white:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(aisleBorderRadius)),
          aisleWhiteShadowPaint,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.shift(Offset(0, -hardShadowHeight)),
            Radius.circular(aisleBorderRadius),
          ),
          aisleWhitePaint,
        );
    }
  }

  void _paintAisleGroup(
    Canvas canvas,
    Size size,
    List<map_model.Aisle> aisles,
  ) {
    final scaleX = size.width / dimension;
    final scaleY = size.height / dimension;

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
        Radius.circular(9),
      );
      combinedPath = Path.combine(
        PathOperation.union,
        combinedPath,
        Path()..addRRect(rect),
      );
    }

    // Get a sample aisle for status (assume all in group have same status)
    final sampleAisle = aisles.first;

    switch (sampleAisle.status) {
      case map_model.AisleStatus.black:
        // Obstruction shadow
        canvas.drawPath(combinedPath, aisleBlackShadowPaint);

        canvas.drawPath(combinedPath.shift(softShadowOffset), softShadowPaint);

        // Obstruction
        canvas.drawPath(
          combinedPath.shift(Offset(0, -hardShadowHeight)),
          aisleBlackPaint,
        );
        break;

      case map_model.AisleStatus.grey:
        // Obstruction shadow
        canvas.drawPath(combinedPath, aisleGreyShadowPaint);

        canvas.drawPath(combinedPath.shift(softShadowOffset), softShadowPaint);

        // Obstruction
        canvas.drawPath(
          combinedPath.shift(Offset(0, -hardShadowHeight)),
          aisleGreyPaint,
        );

        break;
      case map_model.AisleStatus.white:
        // Obstruction shadow
        canvas.drawPath(combinedPath, aisleWhiteShadowPaint);

        // Obstruction
        canvas.drawPath(
          combinedPath.shift(Offset(0, -hardShadowHeight)),
          aisleWhitePaint,
        );
    }
  }

  void _paintIsles(Canvas canvas, Size size, map_model.Map map) {
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
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width, size.height, backgroundBorderRadius),
      backgroundPaint,
    );
  }
}
