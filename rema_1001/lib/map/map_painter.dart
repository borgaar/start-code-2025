import 'package:flutter/widgets.dart';
import 'package:rema_1001/map/map.dart' as map_model;

final dimension = 64;

final borderRadius = Radius.circular(16);
final backgroundPaint = Paint()..color = const Color(0xff434343);
final borderPaint = Paint()
  ..color = const Color(0xff2C2C2C)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 30
  ..strokeCap = StrokeCap.round;

final aislePaint = Paint()..color = const Color(0xFF636363);
final aisleShadowPaint = Paint()..color = const Color(0xff4A4A4A);

final obstructionPaint = Paint()..color = const Color(0xff2C2C2C);

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

    // Soft shadow
    if (aisle.status != map_model.AisleStatus.highlighted) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.shift(Offset(4, 12)), Radius.circular(9)),
        Paint()
          ..color = const Color(0x52000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Hard shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(9)),
      aisleShadowPaint,
    );

    // Aisle
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(Offset(0, -6)), Radius.circular(9)),
      aislePaint,
    );
  }

  void _paintIsles(Canvas canvas, Size size, map_model.Map map) {
    for (final aisle in map.aisles) {
      _paintIsle(canvas, size, aisle);
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width, size.height, borderRadius),
      backgroundPaint,
    );
  }
}
