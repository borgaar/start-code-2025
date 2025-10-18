import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rema_1001/data/models/aisle.dart' as aisle_model;
import 'package:rema_1001/data/models/product.dart';
import 'package:rema_1001/data/models/product_in_aisle.dart';
import 'package:rema_1001/data/models/store.dart';
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
  Timer? _pollingTimer;
  List<aisle_model.Aisle>? _previousAisles;
  Store? _previousStore;

  void intialize() async {
    try {
      emit(MapInitial());
      final aisles = await _aisleRepository.getAislesForStore(storeSlug);

      // Store aisles for comparison in polling
      _previousAisles = aisles;
      final shoppingList = await _shoppingListRepository
          .getShoppingListWithAisles(id: shoppingListId, storeSlug: storeSlug);
      final store = await _storeRepository.getStoreBySlug(storeSlug);

      // Store store data (entrance/exit) for comparison in polling
      _previousStore = store;

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

      emit(
        MapLoaded(
          map: map,
          currentStep: 0,
          aisleGroups: aisleGroups,
          storeName: store.name,
        ),
      );

      final pathFuture = calculatePathInIsolate(
        aisles: pathfindingAisles,
        start: store.entrance,
        end: store.exit,
      );

      final discountedProductsFuture = Future.wait(
        aisleGroups.map(
          (group) async => (
            group.aisleId,
            await _aisleRepository.getProductsInAisle(storeSlug, group.aisleId),
          ),
        ),
      );

      final result = await Future.wait([pathFuture, discountedProductsFuture]);
      final path = result[0] as List<Waypoint>;
      final discountedProductsPerAisle =
          result[1] as List<(String, List<ProductInAisle>)>;

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

      // Update aisle colors based on their position in the waypoint path
      final updatedAisles = map.aisles.mapIndexed((aisleIdx, aisle) {
        // Current target aisle should blink
        if (aisleIdx == targetAisleIdx) {
          return aisle.copyWith(status: AisleStatus.blinking);
        }

        // Find this aisle's waypoint position in the path
        final aisleWaypointIdx = path.indexWhere(
          (w) => w.targetAisleIndex == aisleIdx,
        );

        // If aisle is not in the path (obstacle or non-target), keep it black
        if (aisleWaypointIdx == -1) {
          return aisle.copyWith(status: AisleStatus.black);
        }

        // At step 0, no aisles are behind us yet
        // Aisles ahead of us in the path are grey
        if (aisleWaypointIdx > targetWaypointIdx) {
          return aisle.copyWith(status: AisleStatus.grey);
        }

        if (aisleWaypointIdx < targetWaypointIdx) {
          return aisle.copyWith(status: AisleStatus.white);
        }

        return aisle;
      }).toList();

      final updatedMap = MapModel(aisles: updatedAisles);

      // reorder aisleGroups based on path
      final orderedAisleGroupDiscountedProducts = path
          .where((w) => w.targetAisleIndex != null)
          .map(
            (waypoint) => discountedProductsPerAisle
                .firstWhereOrNull(
                  (group) => group.$1 == aisles[waypoint.targetAisleIndex!].id,
                )
                ?.$2,
          )
          .whereType<List<ProductInAisle>>()
          .toList();

      final finishedAisleGroups = orderedAisleGroups
          .mapIndexed(
            (index, group) => group.copyWith(
              discountedItems: orderedAisleGroupDiscountedProducts[index]
                  .where((pia) => pia.product.discount != null)
                  .map(
                    (pia) => DiscountedAisleItem(
                      productId: pia.productId,
                      productName: pia.product.name,
                      discountPercentage: pia.product.discount ?? 0,
                      price: pia.product.price,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();

      emit(
        MapPathfindingLoaded(
          map: updatedMap,
          path: path,
          currentStep: 0,
          aisleGroups: finishedAisleGroups,
          currentWaypointIndex: targetWaypointIdx,
          storeName: store.name,
        ),
      );

      // Start polling for aisle changes in the background
      _startPolling();
    } catch (e) {
      emit(MapError('Failed to load map data: $e'));
    }
  }

  /// Navigate to a specific step in the shopping journey
  /// Updates aisle colors based on their position in the waypoint path:
  /// - Target aisle: blinking
  /// - Aisles behind us in the path: white
  /// - Aisles ahead of us in the path: grey
  /// - Obstacles/non-targets: black
  /// Special case: when newStep == aisleGroups.length (the "done" step),
  /// all target aisles turn white and the path extends to the very end
  void _navigateToStep(int newStep) {
    final s = state;
    if (s is! MapPathfindingLoaded) return;

    // Validate bounds (allow up to aisleGroups.length for the "done" step)
    if (newStep < 0 || newStep > s.aisleGroups.length) return;

    // Special case: "done" step - show all aisles as white, path to the end
    if (newStep == s.aisleGroups.length) {
      final updatedAisles = s.map.aisles.mapIndexed((aisleIdx, aisle) {
        // Find this aisle's waypoint position in the path
        final aisleWaypointIdx = s.path.indexWhere(
          (w) => w.targetAisleIndex == aisleIdx,
        );

        // If aisle is not in the path (obstacle or non-target), keep it black
        if (aisleWaypointIdx == -1) {
          return aisle.copyWith(status: AisleStatus.black);
        }

        // All target aisles are white at the "done" step
        return aisle.copyWith(status: AisleStatus.white);
      }).toList();

      final updatedMap = MapModel(aisles: updatedAisles);

      emit(
        MapPathfindingLoaded(
          map: updatedMap,
          aisleGroups: s.aisleGroups,
          currentStep: newStep,
          path: s.path,
          currentWaypointIndex: s.path.length - 1, // End of path
          storeName: s.storeName,
        ),
      );
      return;
    }

    // Regular step navigation
    // Calculate waypoint index for the current step
    final currentAisleGroup = s.aisleGroups[newStep];
    final targetAisleIdx = s.map.aisles.indexWhere(
      (aisle) => aisle.id == currentAisleGroup.aisleId,
    );
    final targetWaypointIdx = s.path.indexWhere(
      (w) => w.targetAisleIndex == targetAisleIdx,
    );

    // Update aisle statuses based on their position in the waypoint path
    final updatedAisles = s.map.aisles.mapIndexed((aisleIdx, aisle) {
      // Current target aisle should blink
      if (aisleIdx == targetAisleIdx) {
        return aisle.copyWith(status: AisleStatus.blinking);
      }

      // Find this aisle's waypoint position in the path
      final aisleWaypointIdx = s.path.indexWhere(
        (w) => w.targetAisleIndex == aisleIdx,
      );

      // If aisle is not in the path (obstacle or non-target), keep it black
      if (aisleWaypointIdx == -1) {
        return aisle.copyWith(status: AisleStatus.black);
      }

      // Aisles behind us in the path are white
      if (aisleWaypointIdx < targetWaypointIdx) {
        return aisle.copyWith(status: AisleStatus.white);
      }

      // Aisles ahead of us in the path are grey
      if (aisleWaypointIdx > targetWaypointIdx) {
        return aisle.copyWith(status: AisleStatus.grey);
      }

      return aisle;
    }).toList();

    final updatedMap = MapModel(aisles: updatedAisles);

    emit(
      MapPathfindingLoaded(
        map: updatedMap,
        aisleGroups: s.aisleGroups,
        currentStep: newStep,
        path: s.path,
        currentWaypointIndex: targetWaypointIdx,
        storeName: s.storeName,
      ),
    );
  }

  void next() {
    final s = state;
    if (s is! MapPathfindingLoaded) return;

    final nextStep = s.currentStep + 1;
    _navigateToStep(nextStep);
  }

  void previous() {
    final s = state;
    if (s is! MapPathfindingLoaded) return;

    final previousStep = s.currentStep - 1;
    _navigateToStep(previousStep);
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
        storeName: currentState.storeName,
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

  /// Start polling the backend every 1 second for aisle changes
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) async {
      await _checkForAisleChanges();
    });
  }

  /// Check if aisles or store entrance/exit have changed and reinitialize if needed
  Future<void> _checkForAisleChanges() async {
    try {
      final currentAisles = await _aisleRepository.getAislesForStore(storeSlug);
      final currentStore = await _storeRepository.getStoreBySlug(storeSlug);

      // Skip if no previous data stored yet (shouldn't happen)
      if (_previousAisles == null || _previousStore == null) {
        _previousAisles = currentAisles;
        _previousStore = currentStore;
        return;
      }

      // Check if aisles or store entrance/exit have changed
      final aislesChanged = _hasAislesChanged(_previousAisles!, currentAisles);
      final storeChanged = _hasStoreChanged(_previousStore!, currentStore);

      if (aislesChanged || storeChanged) {
        _previousAisles = currentAisles;
        _previousStore = currentStore;
        intialize();
      }
    } catch (e) {
      // Silently fail - don't disrupt the user experience
      debugPrint('Failed to check for changes: $e');
    }
  }

  /// Compare two aisle lists to detect changes
  bool _hasAislesChanged(
    List<aisle_model.Aisle> previous,
    List<aisle_model.Aisle> current,
  ) {
    if (previous.length != current.length) return true;

    // Compare each aisle by ID and key properties
    for (int i = 0; i < previous.length; i++) {
      final prev = previous[i];
      final curr = current.firstWhereOrNull((a) => a.id == prev.id);

      if (curr == null) return true;

      // Check if position, size, or type has changed
      if (prev.position != curr.position ||
          prev.width != curr.width ||
          prev.height != curr.height ||
          prev.type != curr.type) {
        return true;
      }
    }

    return false;
  }

  /// Compare two store objects to detect entrance/exit changes
  bool _hasStoreChanged(Store previous, Store current) {
    // Check if entrance or exit positions have changed
    return previous.entrance != current.entrance ||
        previous.exit != current.exit;
  }

  @override
  void onChange(Change<MapState> change) {
    last = change.currentState;
    super.onChange(change);
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
