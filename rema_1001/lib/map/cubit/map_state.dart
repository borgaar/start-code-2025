part of 'map_cubit.dart';

sealed class MapState extends Equatable {
  const MapState();
}

final class MapInitial extends MapState {
  @override
  List<Object?> get props => [];
}

final class MapLoaded extends MapState {
  final MapModel map;
  final List<Waypoint> path;
  final int currentStep;

  const MapLoaded({
    required this.map,
    required this.path,
    required this.currentStep,
  });

  @override
  List<Object?> get props => [map, path, currentStep];
}
