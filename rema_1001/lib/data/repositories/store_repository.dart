import '../models/store.dart';

abstract class StoreRepository {
  /// Get all stores
  Future<List<Store>> getStores();

  /// Get a store by slug/id
  Future<Store> getStoreBySlug(String slug);

  /// Create a new store
  Future<Store> createStore({required String name, required String slug});

  /// Update a store
  Future<Store> updateStore({
    required String slug,
    String? name,
    int? entranceX,
    int? entranceY,
    int? exitX,
    int? exitY,
  });

  /// Delete a store
  Future<void> deleteStore(String slug);
}
