import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rema_1001/map/model.dart';
import 'package:rema_1001/map/pathfinding/pathfinding_aisle.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapInitial());

  void intialize() {}

  void checkItem() {}
}
