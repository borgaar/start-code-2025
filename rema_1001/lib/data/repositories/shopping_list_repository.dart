import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';

abstract class ShoppingListRepository {
  /// Get all shopping lists
  Future<List<ShoppingList>> getShoppingLists();

  /// Get a shopping list by ID
  Future<ShoppingList> getShoppingListById(String id);

  /// Get a shopping list with aisle locations for a specific store
  Future<ShoppingList> getShoppingListWithAisles({
    required String id,
    required String storeSlug,
  });

  /// Create a new shopping list
  Future<ShoppingList> createShoppingList(String name);

  /// Update a shopping list
  Future<ShoppingList> updateShoppingList(String id, String name);

  /// Delete a shopping list
  Future<void> deleteShoppingList(String id);

  /// Add an item to a shopping list
  Future<ShoppingListItem> addItemToShoppingList({
    required String shoppingListId,
    required String productId,
    required bool checked,
    int? quantity,
  });

  /// Update an item in a shopping list
  Future<ShoppingListItem> updateShoppingListItem({
    required String shoppingListId,
    required String itemId,
    int? quantity,
    bool? checked,
  });

  /// Remove an item from a shopping list
  Future<void> removeItemFromShoppingList({
    required String shoppingListId,
    required String itemId,
  });
}
