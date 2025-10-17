import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/models/shopping_list.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'shopping_lists_state.dart';

class ShoppingListsCubit extends Cubit<ShoppingListsState> {
  final ShoppingListRepository _repository;

  ShoppingListsCubit({required ShoppingListRepository repository})
    : _repository = repository,
      super(ShoppingListsInitial());

  /// Load all shopping lists
  Future<void> loadShoppingLists({bool emitLoading = false}) async {
    if (emitLoading) emit(ShoppingListsLoading());
    try {
      final lists = await _repository.getShoppingLists();
      emit(ShoppingListsLoaded(lists));
    } catch (e) {
      emit(ShoppingListsError('Failed to load shopping lists: $e'));
    }
  }

  /// Create a new shopping list with optimistic update
  Future<void> createShoppingList(String name) async {
    final currentState = state;
    if (currentState is! ShoppingListsLoaded) return;

    // Optimistic update: add temporary list
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toIso8601String();
    final tempList = ShoppingList(
      id: tempId,
      name: name,
      createdAt: now,
      updatedAt: now,
      items: const [],
    );

    final optimisticLists = [tempList, ...currentState.shoppingLists];
    emit(ShoppingListsLoaded(optimisticLists));

    try {
      final newList = await _repository.createShoppingList(name);
      // Replace temp list with real one from server
      emit(ShoppingListsLoaded([newList, ...currentState.shoppingLists]));
    } catch (e) {
      // Revert optimistic update on error
      emit(ShoppingListsLoaded(currentState.shoppingLists));
      emit(ShoppingListsError('Failed to create shopping list: $e'));
      // Restore the loaded state
      emit(ShoppingListsLoaded(currentState.shoppingLists));
    }
  }

  /// Update a shopping list name with optimistic update
  Future<void> updateShoppingList(String id, String newName) async {
    final currentState = state;
    if (currentState is! ShoppingListsLoaded) return;

    // Store original lists for rollback
    final originalLists = currentState.shoppingLists;

    // Optimistic update
    final optimisticLists = currentState.shoppingLists.map((list) {
      if (list.id == id) {
        return list.copyWith(
          name: newName,
          updatedAt: DateTime.now().toIso8601String(),
        );
      }
      return list;
    }).toList();
    emit(ShoppingListsLoaded(optimisticLists));

    try {
      final updatedList = await _repository.updateShoppingList(id, newName);
      // Replace with server response
      final updatedLists = currentState.shoppingLists.map((list) {
        return list.id == id ? updatedList : list;
      }).toList();
      emit(ShoppingListsLoaded(updatedLists));
    } catch (e) {
      // Revert on error
      emit(ShoppingListsLoaded(originalLists));
      emit(ShoppingListsError('Failed to update shopping list: $e'));
      emit(ShoppingListsLoaded(originalLists));
    }
  }

  /// Delete a shopping list with optimistic update
  Future<void> deleteShoppingList(String id) async {
    final currentState = state;
    if (currentState is! ShoppingListsLoaded) return;

    // Store original for rollback
    final originalLists = currentState.shoppingLists;

    // Optimistic update: remove from list
    final optimisticLists = currentState.shoppingLists
        .where((list) => list.id != id)
        .toList();
    emit(ShoppingListsLoaded(optimisticLists));

    try {
      await _repository.deleteShoppingList(id);
      // Keep the optimistic state since deletion succeeded
    } catch (e) {
      // Revert on error
      emit(ShoppingListsLoaded(originalLists));
      emit(ShoppingListsError('Failed to delete shopping list: $e'));
      emit(ShoppingListsLoaded(originalLists));
    }
  }
}
