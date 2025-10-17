import 'dart:developer' as developer;

import '../api/api_client.dart';
import '../models/aisle.dart';
import '../models/product_in_aisle.dart';
import '../models/store.dart';
import 'store_repository.dart';

class StoreRepositoryImpl implements StoreRepository {
  final ApiClient _apiClient;

  StoreRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Store>> getStores() async {
    try {
      final response = await _apiClient.get('/api/store');
      if (response is List) {
        return response
            .map((json) => Store.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ApiException('Unexpected response format');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch stores',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch stores: $e');
    }
  }

  @override
  Future<Store> getStoreBySlug(String slug) async {
    try {
      final response = await _apiClient.get('/api/store/$slug');
      return Store.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch store by slug: $slug',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch store: $e');
    }
  }

  @override
  Future<Store> createStore(String name) async {
    try {
      final response = await _apiClient.post(
        '/api/store',
        body: {'name': name},
      );
      return Store.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create store: $name',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to create store: $e');
    }
  }

  @override
  Future<Store> updateStore(String slug, String name) async {
    try {
      final response = await _apiClient.patch(
        '/api/store/$slug',
        body: {'name': name},
      );
      return Store.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update store: $slug',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to update store: $e');
    }
  }

  @override
  Future<void> deleteStore(String slug) async {
    try {
      await _apiClient.delete('/api/store/$slug');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete store: $slug',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to delete store: $e');
    }
  }

  @override
  Future<List<Aisle>> getAisles(String storeSlug) async {
    try {
      final response = await _apiClient.get('/api/store/$storeSlug/aisle');
      if (response is List) {
        return response
            .map((json) => Aisle.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ApiException('Unexpected response format');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch aisles for store: $storeSlug',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch aisles: $e');
    }
  }

  @override
  Future<Aisle> getAisle(String storeSlug, String aisleId) async {
    try {
      final response = await _apiClient.get(
        '/api/store/$storeSlug/aisle/$aisleId',
      );
      return Aisle.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch aisle: $aisleId from store: $storeSlug',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch aisle: $e');
    }
  }

  @override
  Future<Aisle> createAisle({
    required String storeSlug,
    required String name,
    required AisleType type,
    required int gridX,
    required int gridY,
    required int width,
    required int height,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/store/$storeSlug/aisle',
        body: {
          'name': name,
          'type': type.name,
          'gridX': gridX,
          'gridY': gridY,
          'width': width,
          'height': height,
        },
      );
      return Aisle.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create aisle in store: $storeSlug',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to create aisle: $e');
    }
  }

  @override
  Future<Aisle> updateAisle({
    required String storeSlug,
    required String aisleId,
    required String name,
    required AisleType type,
    required int gridX,
    required int gridY,
    required int width,
    required int height,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/api/store/$storeSlug/aisle/$aisleId',
        body: {
          'name': name,
          'type': type.name,
          'gridX': gridX,
          'gridY': gridY,
          'width': width,
          'height': height,
        },
      );
      return Aisle.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update aisle: $aisleId in store: $storeSlug',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to update aisle: $e');
    }
  }

  @override
  Future<void> deleteAisle(String storeSlug, String aisleId) async {
    try {
      await _apiClient.delete('/api/store/$storeSlug/aisle/$aisleId');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete aisle: $aisleId from store: $storeSlug',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to delete aisle: $e');
    }
  }

  @override
  Future<List<String>> getAisleTypes() async {
    try {
      final response = await _apiClient.get('/api/store/aisle-types');
      if (response is List) {
        return response.map((type) => type as String).toList();
      }
      throw ApiException('Unexpected response format');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch aisle types',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch aisle types: $e');
    }
  }

  @override
  Future<List<ProductInAisle>> getProductsInAisle(
    String storeSlug,
    String aisleId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/api/store/$storeSlug/aisle/$aisleId/products',
      );
      if (response is List) {
        return response
            .map(
              (json) => ProductInAisle.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw ApiException('Unexpected response format');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch products in aisle: $aisleId from store: $storeSlug',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch products in aisle: $e');
    }
  }

  @override
  Future<ProductInAisle> addProductToAisle({
    required String productId,
    required String aisleId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/store/product-in-aisle',
        body: {'productId': productId, 'aisleId': aisleId},
      );
      return ProductInAisle.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to add product: $productId to aisle: $aisleId',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to add product to aisle: $e');
    }
  }

  @override
  Future<void> removeProductFromAisle({
    required String productId,
    required String aisleId,
  }) async {
    try {
      await _apiClient.delete(
        '/api/store/product-in-aisle/$productId/$aisleId',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to remove product: $productId from aisle: $aisleId',
        name: 'StoreRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to remove product from aisle: $e');
    }
  }
}
