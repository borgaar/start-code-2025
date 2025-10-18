import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

final class PathfindingAisle extends Equatable {
  final Offset topLeft;
  final int height;
  final int width;
  final bool isTarget;

  const PathfindingAisle({
    required this.topLeft,
    required this.height,
    required this.width,
    required this.isTarget,
  });

  @override
  List<Object?> get props => [topLeft, height, width, isTarget];
}

final class Waypoint extends Equatable {
  final Offset position;
  final int? targetAisleIndex;

  const Waypoint({required this.position, required this.targetAisleIndex});

  @override
  List<Object?> get props => [position, targetAisleIndex];
}
