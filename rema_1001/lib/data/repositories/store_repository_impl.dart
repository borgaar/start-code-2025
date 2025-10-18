import 'dart:developer' as developer;

import '../api/api_client.dart';
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
  Future<Store> createStore({
    required String name,
    required String slug,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/store',
        body: {'name': name, 'slug': slug},
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
  Future<Store> updateStore({
    required String slug,
    String? name,
    int? entranceX,
    int? entranceY,
    int? exitX,
    int? exitY,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (entranceX != null) body['entranceX'] = entranceX;
      if (entranceY != null) body['entranceY'] = entranceY;
      if (exitX != null) body['exitX'] = exitX;
      if (exitY != null) body['exitY'] = exitY;

      final response = await _apiClient.put('/api/store/$slug', body: body);
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
}
