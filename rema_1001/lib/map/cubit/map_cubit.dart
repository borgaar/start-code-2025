import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rema_1001/data/models/aisle.dart' as aisle_model;
import 'package:rema_1001/data/repositories/aisle_repository.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'package:rema_1001/data/repositories/store_repository.dart';
import 'package:rema_1001/map/cubit/calculate_path_in_isolate.dart';
import 'package:rema_1001/map/cubit/reolve_product_isles.dart';
import 'package:rema_1001/map/model.dart';
import 'package:rema_1001/map/pathfinding/pathfinding_aisle.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit(
    this._aisleRepository,
    this._shoppingListRepository,
    this._storeRepository,
  ) : super(MapInitial());

  final AisleRepository _aisleRepository;
  final ShoppingListRepository _shoppingListRepository;
  final StoreRepository _storeRepository;

  MapState? last;

  void intialize() async {
    emit(MapInitial());
    final allShoppingLists = await _shoppingListRepository.getShoppingLists();
    final shoppingListid = allShoppingLists.first.id;
    final aisles = await _aisleRepository.getAislesForStore("elgeseter");
    final shoppingList = await _shoppingListRepository
        .getShoppingListWithAisles(id: shoppingListid, storeSlug: "elgeseter");
    final store = await _storeRepository.getStoreBySlug("elgeseter");

    final aisleGroups = resolveProductIsles(
      shoppingList: shoppingList,
      aisles: aisles,
    );

    final pathfindingAisles = aisles.mapIndexed((idx, a) {
      return PathfindingAisle(
        topLeft: a.position,
        width: a.width,
        height: a.height,
        isTarget: aisleGroups.any((group) => group.aisleId == a.id),
        id: a.id,
      );
    }).toList();

    final map = MapModel(
      aisles: aisles.mapIndexed((idx, a) {
        AisleStatus status;

        if (a.type == aisle_model.AisleType.OBSTACLE ||
            !pathfindingAisles.any((pa) => pa.id == a.id && pa.isTarget)) {
          status = AisleStatus.black;
        } else {
          status = AisleStatus.grey;
        }

        return Aisle(
          topLeft: a.position,
          width: a.width.toDouble(),
          height: a.height.toDouble(),
          status: status,
        );
      }).toList(),
    );

    emit(MapLoaded(map: map, currentStep: 0, aisleGroups: aisleGroups));

    final path = await calculatePathInIsolate(
      aisles: pathfindingAisles,
      start: store.entrance,
      end: store.exit,
    );

    emit(
      MapPathfindingLoaded(
        map: map,
        path: path,
        currentStep: 0,
        aisleGroups: aisleGroups,
      ),
    );
  }

  void next() {
    // emit(
    //   MapLoaded(
    //     map: MapModel(
    //       walkPoints: [],
    //       aisles: [
    //         // Right tall vertical rectangle
    //         Aisle(topLeft: Offset(46, 17), width: 4, height: 18),

    //         // Lower-middle left rectangle
    //         Aisle(topLeft: Offset(10, 27), width: 18, height: 7),

    //         // Lower-middle center rectangle
    //         Aisle(
    //           topLeft: Offset(31, 27),
    //           width: 12,
    //           height: 7,
    //           status: AisleStatus.white,
    //         ),
    //       ],
    //     ),
    //     path: [],
    //     currentStep: 0,
    //   ),
    // );
  }

  void checkItem() {}

  @override
  void onChange(Change<MapState> change) {
    last = change.currentState;
    super.onChange(change);
  }
}
