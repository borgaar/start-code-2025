import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'shopping_list_detail_state.dart';

class ShoppingListDetailCubit extends Cubit<ShoppingListDetailState> {
  final ShoppingListRepository _repository;
  final String listId;

  ShoppingListDetailCubit({
    required ShoppingListRepository repository,
    required this.listId,
  }) : _repository = repository,
       super(ShoppingListDetailInitial()) {
    loadShoppingList();
  }

  /// Load shopping list with items
  Future<void> loadShoppingList({bool emitLoading = false}) async {
    if (emitLoading) emit(ShoppingListDetailLoading());
    try {
      final list = await _repository.getShoppingListById(listId);
      emit(ShoppingListDetailLoaded(list));
    } catch (e) {
      emit(ShoppingListDetailError('Failed to load shopping list: $e'));
    }
  }

  /// Toggle item checked status with optimistic update
  Future<void> toggleItemChecked(String itemId, bool currentStatus) async {
    final currentState = state;
    if (currentState is! ShoppingListDetailLoaded) return;

    final originalList = currentState.shoppingList;

    // Optimistic update
    final optimisticItems = originalList.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(checked: !currentStatus);
      }
      return item;
    }).toList();

    emit(
      ShoppingListDetailLoaded(originalList.copyWith(items: optimisticItems)),
    );

    try {
      await _repository.updateShoppingListItem(
        shoppingListId: listId,
        itemId: itemId,
        checked: !currentStatus,
      );
    } catch (e) {
      // Revert on error
      emit(ShoppingListDetailLoaded(originalList));
      emit(ShoppingListDetailError('Failed to update item: $e'));
      emit(ShoppingListDetailLoaded(originalList));
    }
  }

  /// Update item quantity with optimistic update
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    final currentState = state;
    if (currentState is! ShoppingListDetailLoaded) return;

    final originalList = currentState.shoppingList;

    // Optimistic update
    final optimisticItems = originalList.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    emit(
      ShoppingListDetailLoaded(originalList.copyWith(items: optimisticItems)),
    );

    try {
      await _repository.updateShoppingListItem(
        shoppingListId: listId,
        itemId: itemId,
        quantity: newQuantity,
      );
    } catch (e) {
      // Revert on error
      emit(ShoppingListDetailLoaded(originalList));
      emit(ShoppingListDetailError('Failed to update quantity: $e'));
      emit(ShoppingListDetailLoaded(originalList));
    }
  }

  /// Remove item from list with optimistic update
  Future<void> removeItem(String itemId) async {
    final currentState = state;
    if (currentState is! ShoppingListDetailLoaded) return;

    final originalList = currentState.shoppingList;

    // Optimistic update
    final optimisticItems = originalList.items
        .where((item) => item.id != itemId)
        .toList();

    emit(
      ShoppingListDetailLoaded(originalList.copyWith(items: optimisticItems)),
    );

    try {
      await _repository.removeItemFromShoppingList(
        shoppingListId: listId,
        itemId: itemId,
      );
    } catch (e) {
      // Revert on error
      emit(ShoppingListDetailLoaded(originalList));
      emit(ShoppingListDetailError('Failed to remove item: $e'));
      emit(ShoppingListDetailLoaded(originalList));
    }
  }

  /// Add item to list with optimistic update
  Future<void> addItem(String productId, int quantity) async {
    final currentState = state;
    if (currentState is! ShoppingListDetailLoaded) return;

    try {
      await _repository.addItemToShoppingList(
        shoppingListId: listId,
        productId: productId,
        quantity: quantity,
      );
      loadShoppingList();
    } catch (e) {
      emit(ShoppingListDetailError('Failed to add item: $e'));
      // Re-emit loaded state
      emit(currentState);
    }
  }
}
