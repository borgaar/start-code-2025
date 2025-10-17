import '../models/product.dart';

abstract class ProductRepository {
  /// Get all products
  Future<List<Product>> getProducts();

  /// Get a product by ID
  Future<Product> getProductById(String id);
}
