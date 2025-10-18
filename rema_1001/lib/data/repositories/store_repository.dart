import '../models/aisle.dart';
import '../models/product_in_aisle.dart';
import '../models/store.dart';

abstract class StoreRepository {
  /// Get all stores
  Future<List<Store>> getStores();

  /// Get a store by slug/id
  Future<Store> getStoreBySlug(String slug);

  /// Create a new store
  Future<Store> createStore({required String name, required String slug});

  /// Update a store
  Future<Store> updateStore(String slug, String name);

  /// Delete a store
  Future<void> deleteStore(String slug);

  /// Get all aisles for a store
  Future<List<Aisle>> getAisles(String storeSlug);

  /// Get all aisles with products for a store
  Future<List<Map<String, dynamic>>> getAislesWithProducts(String storeSlug);

  /// Get a specific aisle
  Future<Aisle> getAisle(String storeSlug, String aisleId);

  /// Create a new aisle for a store
  Future<Aisle> createAisle({
    required String storeSlug,
    required AisleType type,
    required int gridX,
    required int gridY,
    required int width,
    required int height,
  });

  /// Update an aisle
  Future<Aisle> updateAisle({
    required String storeSlug,
    required String aisleId,
    AisleType? type,
    int? gridX,
    int? gridY,
    int? width,
    int? height,
  });

  /// Delete an aisle
  Future<void> deleteAisle(String storeSlug, String aisleId);

  /// Get all available aisle types
  Future<List<String>> getAisleTypes();

  /// Get all products in an aisle
  Future<List<ProductInAisle>> getProductsInAisle(
    String storeSlug,
    String aisleId,
  );

  /// Add a product to an aisle
  Future<ProductInAisle> addProductToAisle({
    required String productId,
    required String aisleId,
  });

  /// Remove a product from an aisle
  Future<void> removeProductFromAisle({
    required String productId,
    required String aisleId,
  });
}
