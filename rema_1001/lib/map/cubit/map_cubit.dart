import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rema_1001/map/model.dart';
import 'package:rema_1001/map/pathfinding/pathfinding_aisle.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapInitial());

  MapState? last;

  void intialize() async {
    emit(
      MapLoaded(
        map: MapModel(
          walkPoints: [],
          aisles: [
            // Right tall vertical rectangle
            Aisle(topLeft: Offset(46, 17), width: 4, height: 18),

            // Lower-middle left rectangle
            Aisle(topLeft: Offset(10, 27), width: 18, height: 7),

            // Lower-middle center rectangle
            Aisle(
              topLeft: Offset(31, 27),
              width: 12,
              height: 7,
              status: AisleStatus.grey,
            ),
          ],
        ),
        path: [],
        currentStep: 0,
      ),
    );
  }

  void next() {
    emit(
      MapLoaded(
        map: MapModel(
          walkPoints: [],
          aisles: [
            // Right tall vertical rectangle
            Aisle(topLeft: Offset(46, 17), width: 4, height: 18),

            // Lower-middle left rectangle
            Aisle(topLeft: Offset(10, 27), width: 18, height: 7),

            // Lower-middle center rectangle
            Aisle(
              topLeft: Offset(31, 27),
              width: 12,
              height: 7,
              status: AisleStatus.white,
            ),
          ],
        ),
        path: [],
        currentStep: 0,
      ),
    );
  }

  void checkItem() {}

  @override
  void onChange(Change<MapState> change) {
    last = change.currentState;
    super.onChange(change);
  }
}
