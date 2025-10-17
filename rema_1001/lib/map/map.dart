import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

final class Map extends Equatable {
  final List<Offset> walkPoints;
  final List<Aisle> aisles;

  const Map({required this.walkPoints, required this.aisles});

  @override
  List<Object?> get props => [walkPoints, aisles];
}

enum AisleStatus { black, grey, white }

final class Aisle extends Equatable {
  final Offset topLeft;
  final double width;
  final double height;
  final AisleStatus status;

  const Aisle({
    required this.topLeft,
    required this.width,
    required this.height,
    this.status = AisleStatus.black,
  });

  @override
  List<Object?> get props => [topLeft, width, height];
}
