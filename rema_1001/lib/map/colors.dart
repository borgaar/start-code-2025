import 'package:flutter/material.dart';

final aisleGreyPaint = Paint()..color = const Color(0xFF636363);
final aisleGreyShadowPaint = Paint()
  ..color = const Color.fromARGB(255, 71, 71, 71);

final aisleBlackPaint = Paint()..color = const Color(0xff2C2C2C);
final aisleBlackShadowPaint = Paint()..color = const Color(0x5C000000);

final aisleWhitePaint = Paint()..color = const Color(0xffffffff);
final aisleWhiteShadowPaint = Paint()..color = const Color(0xff9A9A9A);

final aisleBlinkingPaint = Paint()..color = const Color(0xffffffff);
final aisleBlinkingShadowPaint = Paint()..color = const Color(0xff9A9A9A);
final aisleBlinkingGlowPaint = Paint()
  ..color = const Color(0xFFFFFFFF)
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 13);

final defaultSoftShadowPaint = Paint()
  ..color = const Color(0x52000000)
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
