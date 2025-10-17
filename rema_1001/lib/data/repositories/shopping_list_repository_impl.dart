import 'dart:developer' as developer;

import '../api/api_client.dart';
import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import 'shopping_list_repository.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ApiClient _apiClient;

  ShoppingListRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ShoppingList>> getShoppingLists() async {
    try {
      final response = await _apiClient.get('/api/shopping-lists');
      if (response is List) {
        return response
            .map((json) => ShoppingList.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ApiException('Unexpected response format');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch shopping lists',
        name: 'ShoppingListRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch shopping lists: $e');
    }
  }

  @override
  Future<ShoppingList> getShoppingListById(String id) async {
    try {
      final response = await _apiClient.get('/api/shopping-lists/$id');
      return ShoppingList.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch shopping list by ID: $id',
        name: 'ShoppingListRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch shopping list: $e');
    }
  }

  @override
  Future<ShoppingList> getShoppingListWithAisles({
    required String id,
    required String storeSlug,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/shopping-lists/$id/aisles/$storeSlug',
      );
      return ShoppingList.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch shopping list with aisles: $id for store: $storeSlug',
        name: 'ShoppingListRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch shopping list with aisles: $e');
    }
  }

  @override
  Future<ShoppingList> createShoppingList(String name) async {
    try {
      final response = await _apiClient.post(
        '/api/shopping-lists',
        body: {'name': name},
      );
      return ShoppingList.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create shopping list: $name',
        name: 'ShoppingListRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to create shopping list: $e');
    }
  }

  @override
  Future<ShoppingList> updateShoppingList(String id, String name) async {
    try {
      final response = await _apiClient.patch(
        '/api/shopping-lists/$id',
        body: {'name': name},
      );
      return ShoppingList.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update shopping list: $id',
        name: 'ShoppingListRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to update shopping list: $e');
    }
  }

  @override
  Future<void> deleteShoppingList(String id) async {
    try {
      await _apiClient.delete('/api/shopping-lists/$id');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete shopping list: $id',
        name: 'ShoppingListRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to delete shopping list: $e');
    }
  }

  @override
  Future<ShoppingListItem> addItemToShoppingList({
    required String shoppingListId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/shopping-lists/$shoppingListId/items',
        body: {'productId': productId, 'quantity': quantity},
      );
      return ShoppingListItem.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to add item to shopping list: $shoppingListId, product: $productId',
        name: 'ShoppingListRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to add item to shopping list: $e');
    }
  }

  @override
  Future<ShoppingListItem> updateShoppingListItem({
    required String shoppingListId,
    required String itemId,
    int? quantity,
    bool? checked,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (quantity != null) body['quantity'] = quantity;
      if (checked != null) body['checked'] = checked;

      final response = await _apiClient.patch(
        '/api/shopping-lists/$shoppingListId/items/$itemId',
        body: body,
      );
      return ShoppingListItem.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update shopping list item: $itemId in list: $shoppingListId',
        name: 'ShoppingListRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to update shopping list item: $e');
    }
  }

  @override
  Future<void> removeItemFromShoppingList({
    required String shoppingListId,
    required String itemId,
  }) async {
    try {
      await _apiClient.delete(
        '/api/shopping-lists/$shoppingListId/items/$itemId',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to remove item from shopping list: $itemId from list: $shoppingListId',
        name: 'ShoppingListRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to remove item from shopping list: $e');
    }
  }
}
