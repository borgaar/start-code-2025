import 'package:equatable/equatable.dart';
import 'product.dart';

class ProductInAisle extends Equatable {
  final String productId;
  final String aisleId;
  final Product product;

  const ProductInAisle({
    required this.productId,
    required this.aisleId,
    required this.product,
  });

  factory ProductInAisle.fromJson(Map<String, dynamic> json) {
    return ProductInAisle(
      productId: json['productId'] as String,
      aisleId: json['aisleId'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'aisleId': aisleId,
      'product': product.toJson(),
    };
  }

  @override
  List<Object?> get props => [productId, aisleId, product];
}
