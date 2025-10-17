import 'dart:developer' as developer;

import '../api/api_client.dart';
import '../models/product.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _apiClient;

  ProductRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await _apiClient.get('/api/products');
      if (response is List) {
        return response
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ApiException('Unexpected response format');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch products',
        name: 'ProductRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch products: $e');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await _apiClient.get('/api/products/$id/$id');
      return Product.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch product by ID: $id',
        name: 'ProductRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw ApiException('Failed to fetch product: $e');
    }
  }
}
