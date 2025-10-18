import 'package:rema_1001/data/api/api_client.dart';
import 'package:rema_1001/data/models/aisle.dart';
import 'package:rema_1001/data/models/aisle_with_products.dart';
import 'package:rema_1001/data/models/product_in_aisle.dart';
import 'package:rema_1001/data/repositories/aisle_repository.dart';

class AisleRepositoryImpl implements AisleRepository {
  final ApiClient apiClient;

  AisleRepositoryImpl({required this.apiClient});

  @override
  Future<List<Aisle>> getAislesForStore(String storeSlug) async {
    try {
      final response = await apiClient.get('/api/store/$storeSlug/aisle');
      return (response as List)
          .map((json) => Aisle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load aisles for store: $e');
    }
  }

  @override
  Future<List<AisleWithProducts>> getAislesWithProducts(
    String storeSlug,
  ) async {
    try {
      final response = await apiClient.get(
        '/api/store/$storeSlug/aisles-products',
      );
      return (response as List)
          .map(
            (json) => AisleWithProducts.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load aisles with products: $e');
    }
  }

  @override
  Future<Aisle> getAisle(String storeSlug, String aisleId) async {
    try {
      final response = await apiClient.get(
        '/api/store/$storeSlug/aisle/$aisleId',
      );
      return Aisle.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load aisle: $e');
    }
  }

  @override
  Future<Aisle> createAisle({
    required String storeSlug,
    required AisleType type,
    required int gridX,
    required int gridY,
    required int width,
    required int height,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/store/$storeSlug/aisle',
        body: {
          'type': type.name,
          'gridX': gridX,
          'gridY': gridY,
          'width': width,
          'height': height,
        },
      );
      return Aisle.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create aisle: $e');
    }
  }

  @override
  Future<Aisle> updateAisle({
    required String storeSlug,
    required String aisleId,
    AisleType? type,
    int? gridX,
    int? gridY,
    int? width,
    int? height,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (type != null) body['type'] = type.name;
      if (gridX != null) body['gridX'] = gridX;
      if (gridY != null) body['gridY'] = gridY;
      if (width != null) body['width'] = width;
      if (height != null) body['height'] = height;

      final response = await apiClient.put(
        '/api/store/$storeSlug/aisle/$aisleId',
        body: body,
      );
      return Aisle.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update aisle: $e');
    }
  }

  @override
  Future<void> deleteAisle(String storeSlug, String aisleId) async {
    try {
      await apiClient.delete('/api/store/$storeSlug/aisle/$aisleId');
    } catch (e) {
      throw Exception('Failed to delete aisle: $e');
    }
  }

  @override
  Future<List<String>> getAisleTypes() async {
    try {
      final response = await apiClient.get('/api/resources/aisle-types');
      return (response as List).map((type) => type as String).toList();
    } catch (e) {
      throw Exception('Failed to load aisle types: $e');
    }
  }

  @override
  Future<ProductInAisle> addProductToAisle({
    required String productId,
    required String aisleId,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/store/product-in-aisle',
        body: {'productId': productId, 'aisleId': aisleId},
      );
      return ProductInAisle.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add product to aisle: $e');
    }
  }

  @override
  Future<void> removeProductFromAisle(String productId, String aisleId) async {
    try {
      await apiClient.delete('/api/store/product-in-aisle/$productId/$aisleId');
    } catch (e) {
      throw Exception('Failed to remove product from aisle: $e');
    }
  }

  @override
  Future<List<ProductInAisle>> getProductsInAisle(
    String storeSlug,
    String aisleId,
  ) async {
    try {
      final response = await apiClient.get(
        '/api/store/$storeSlug/aisle/$aisleId/products',
      );
      return (response as List)
          .map((json) => ProductInAisle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load products in aisle: $e');
    }
  }
}
