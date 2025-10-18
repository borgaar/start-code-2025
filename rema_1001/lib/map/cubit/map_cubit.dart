import 'package:bloc/bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rema_1001/data/models/aisle.dart' as aisle_model;
import 'package:rema_1001/data/models/product.dart';
import 'package:rema_1001/data/models/shopping_list_item.dart';
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
    this.storeSlug,
    this.shoppingListId,
    this._aisleRepository,
    this._shoppingListRepository,
    this._storeRepository,
  ) : super(MapInitial());

  final String storeSlug;
  final String shoppingListId;
  final AisleRepository _aisleRepository;
  final ShoppingListRepository _shoppingListRepository;
  final StoreRepository _storeRepository;
  final carouselSliderController = CarouselSliderController();

  MapState? last;

  void intialize() async {
    emit(MapInitial());
    final aisles = await _aisleRepository.getAislesForStore(storeSlug);
    final shoppingList = await _shoppingListRepository
        .getShoppingListWithAisles(id: shoppingListId, storeSlug: storeSlug);
    final store = await _storeRepository.getStoreBySlug(storeSlug);

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
          id: a.id,
        );
      }).toList(),
    );

    emit(MapLoaded(map: map, currentStep: 0, aisleGroups: aisleGroups));

    final path = await calculatePathInIsolate(
      aisles: pathfindingAisles,
      start: store.entrance,
      end: store.exit,
    );

    // reorder aisleGroups based on path
    final orderedAisleGroups = path
        .where((w) => w.targetAisleIndex != null)
        .map(
          (waypoint) => aisleGroups.firstWhereOrNull(
            (group) => group.aisleId == aisles[waypoint.targetAisleIndex!].id,
          ),
        )
        .whereType<ShoppingListAisleGroup>()
        .toList();

    final targetAisleIdx = map.aisles.indexWhere(
      (aisle) => aisle.id == orderedAisleGroups.first.aisleId,
    );

    final targetWaypointIdx = path.indexWhere(
      (w) => w.targetAisleIndex == targetAisleIdx,
    );

    emit(
      MapPathfindingLoaded(
        map: map,
        path: path,
        currentStep: 0,
        aisleGroups: orderedAisleGroups,
        currentWaypointIndex: targetWaypointIdx,
      ),
    );
  }

  void next() {
    final s = state;
    if (s is! MapPathfindingLoaded) return;

    final nextStep = s.currentStep + 1;
    if (nextStep >= s.aisleGroups.length) return;

    // Get the current aisle group
    final currentAisleGroup = s.aisleGroups[nextStep];

    final targetAisleIdx = s.map.aisles.indexWhere(
      (aisle) => aisle.id == currentAisleGroup.aisleId,
    );

    final targetWaypointIdx = s.path.indexWhere(
      (w) => w.targetAisleIndex == targetAisleIdx,
    );

    // Set the status of the aisles in the current aisle group to blinking
    final updatedAisles = s.map.aisles.mapIndexed((idx, aisle) {
      if (idx == targetAisleIdx) {
        return aisle.copyWith(status: AisleStatus.blinking);
      }
      if (aisle.status == AisleStatus.blinking) {
        return aisle.copyWith(status: AisleStatus.grey);
      }
      return aisle;
    });

    final updatedMap = MapModel(aisles: updatedAisles.toList());

    emit(
      MapPathfindingLoaded(
        map: updatedMap,
        aisleGroups: s.aisleGroups,
        currentStep: nextStep,
        path: s.path,
        currentWaypointIndex: targetWaypointIdx,
      ),
    );

    @override
    void onChange(Change<MapState> change) {
      last = change.currentState;
      super.onChange(change);
    }
  }

  void toggleCheckItem(
    ShoppingListAisleItem item,
    ShoppingListAisleGroup aisle,
  ) {
    final currentState = state;
    if (currentState is! MapPathfindingLoaded) return;

    final updatedAisleGroups = currentState.aisleGroups.map((aisleGroup) {
      if (aisleGroup.aisleId == aisle.aisleId) {
        final updatedItems = aisleGroup.items.map((aisleItem) {
          if (aisleItem.itemId == item.itemId) {
            return aisleItem.copyWith(isChecked: !aisleItem.isChecked);
          }
          return aisleItem;
        }).toList();
        return aisleGroup.copyWith(items: updatedItems);
      }
      return aisleGroup;
    }).toList();

    emit(
      MapPathfindingLoaded(
        map: currentState.map,
        aisleGroups: updatedAisleGroups,
        currentStep: currentState.currentStep,
        path: currentState.path,
        currentWaypointIndex: currentState.currentWaypointIndex,
      ),
    );

    // if all items in the aisle group are checked, move to next aisle
    final currentAisleGroup = updatedAisleGroups[currentState.currentStep];
    final allChecked = currentAisleGroup.items.every((i) => i.isChecked);
    if (allChecked) {
      next();
      carouselSliderController.nextPage();
    }
  }
}
