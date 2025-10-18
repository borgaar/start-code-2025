import 'package:flutter/material.dart';
import 'package:rema_1001/map/model.dart';

final aisleGreyPaint = Paint()..color = const Color(0xFF636363);
final aisleGreyShadowPaint = Paint()
  ..color = const Color.fromARGB(255, 71, 71, 71);

final aisleBlackPaint = Paint()..color = const Color(0xff2C2C2C);
final aisleBlackShadowPaint = Paint()
  ..color = const Color.fromARGB(255, 34, 34, 34);

final aisleWhitePaint = Paint()..color = const Color(0xffffffff);
final aisleWhiteShadowPaint = Paint()..color = const Color(0xff9A9A9A);

final aisleBlinkingPaint = Paint()..color = const Color(0xffffffff);
final aisleBlinkingShadowPaint = Paint()..color = const Color(0xff9A9A9A);
final aisleBlinkingGlowPaint = Paint()
  ..color = const Color(0xFFFFFFFF)
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 13);

final defaultSoftShadowPaint = Paint()
  ..color = const Color.fromARGB(82, 42, 42, 42);
// ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

Paint aislePaint(Color color) => Paint()..color = color;
Paint aisleShadowPaint(Color color) => Paint()..color = color;
Paint aisleGlowPaint(Color color) => Paint()
  ..color = color
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 13);
Paint aisleSoftShadowPaint(Color color) => Paint()..color = color;
// ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

typedef ColorSet = ({
  Paint aislePaint,
  Paint hardShadowPaint,
  Paint softShadowPaint,
  Paint glowPaint,
});

ColorSet getColorSetForAisleStatus(AisleStatus status) {
  switch (status) {
    case AisleStatus.black:
      return (
        aislePaint: aisleBlackPaint,
        hardShadowPaint: aisleBlackShadowPaint,
        softShadowPaint: defaultSoftShadowPaint,
        glowPaint: Paint()..color = Colors.transparent,
      );
    case AisleStatus.grey:
      return (
        aislePaint: aisleGreyPaint,
        hardShadowPaint: aisleGreyShadowPaint,
        softShadowPaint: defaultSoftShadowPaint,
        glowPaint: Paint()..color = Colors.transparent,
      );
    case AisleStatus.white:
      return (
        aislePaint: aisleWhitePaint,
        hardShadowPaint: aisleWhiteShadowPaint,
        softShadowPaint: defaultSoftShadowPaint,
        glowPaint: Paint()..color = Colors.transparent,
      );
    case AisleStatus.blinking:
      return (
        aislePaint: aisleBlinkingPaint,
        hardShadowPaint: aisleBlinkingShadowPaint,
        softShadowPaint: defaultSoftShadowPaint,
        glowPaint: aisleBlinkingGlowPaint,
      );
  }
}
