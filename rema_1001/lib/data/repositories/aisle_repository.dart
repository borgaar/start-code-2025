import 'package:rema_1001/data/models/aisle.dart';
import 'package:rema_1001/data/models/aisle_with_products.dart';
import 'package:rema_1001/data/models/product_in_aisle.dart';

abstract class AisleRepository {
  /// Get all aisles for a store
  Future<List<Aisle>> getAislesForStore(String storeSlug);

  /// Get all aisles with their products for a store
  Future<List<AisleWithProducts>> getAislesWithProducts(String storeSlug);

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
    required AisleType type,
    required int gridX,
    required int gridY,
    required int width,
    required int height,
  });

  /// Delete an aisle
  Future<void> deleteAisle(String storeSlug, String aisleId);

  /// Get all available aisle types
  Future<List<String>> getAisleTypes();

  /// Add a product to an aisle
  Future<ProductInAisle> addProductToAisle({
    required String productId,
    required String aisleId,
  });

  /// Remove a product from an aisle
  Future<void> removeProductFromAisle(String productId, String aisleId);

  /// Get all products in an aisle
  Future<List<ProductInAisle>> getProductsInAisle(
    String storeSlug,
    String aisleId,
  );
}
