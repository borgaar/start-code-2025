import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rema_1001/map/colors.dart';

final class MapModel extends Equatable {
  final List<Aisle> aisles;

  const MapModel({required this.aisles});

  @override
  List<Object?> get props => [aisles];
}

enum AisleStatus { black, grey, white, blinking }

final class Aisle extends Equatable {
  final Offset topLeft;
  final double width;
  final double height;
  final AisleStatus status;
  final double hardShadowHeight;

  late final Paint paint;
  late final Paint hardShadowPaint;
  late final Paint softShadowPaint;
  late final Paint glowPaint;

  Aisle({
    required this.topLeft,
    required this.width,
    required this.height,
    this.status = AisleStatus.black,
    this.hardShadowHeight = 12,
  }) {
    final paints = getColorSetForAisleStatus(status);
    paint = paints.aislePaint;
    hardShadowPaint = paints.hardShadowPaint;
    softShadowPaint = paints.softShadowPaint;
    glowPaint = paints.glowPaint;
  }

  // this lint fucks up the class due to late
  // ignore: prefer_const_constructors_in_immutables
  Aisle.withColor({
    required this.topLeft,
    required this.width,
    required this.height,
    required this.paint,
    required this.hardShadowPaint,
    required this.status,
    required this.softShadowPaint,
    required this.glowPaint,
    required this.hardShadowHeight,
  });

  Aisle copyWith({
    Offset? topLeft,
    double? width,
    double? height,
    AisleStatus? status,
    Paint? paint,
    Paint? hardShadowPaint,
    Paint? softShadowPaint,
    Paint? glowPaint,
    double? hardShadowHeight,
  }) {
    return Aisle.withColor(
      topLeft: topLeft ?? this.topLeft,
      width: width ?? this.width,
      height: height ?? this.height,
      status: status ?? this.status,
      hardShadowPaint: hardShadowPaint ?? this.hardShadowPaint,
      paint: paint ?? this.paint,
      softShadowPaint: softShadowPaint ?? this.softShadowPaint,
      glowPaint: glowPaint ?? this.glowPaint,
      hardShadowHeight: hardShadowHeight ?? this.hardShadowHeight,
    );
  }

  @override
  List<Object?> get props => [
    topLeft,
    width,
    height,
    status,
    hardShadowPaint,
    paint,
    softShadowPaint,
    glowPaint,
  ];
}
