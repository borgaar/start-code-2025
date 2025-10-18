import 'package:equatable/equatable.dart';
import 'dart:ui';
import 'aisle.dart';

/// A lightweight model for product-aisle associations
class ProductAisleAssociation extends Equatable {
  final String productId;
  final String aisleId;

  const ProductAisleAssociation({
    required this.productId,
    required this.aisleId,
  });

  factory ProductAisleAssociation.fromJson(Map<String, dynamic> json) {
    return ProductAisleAssociation(
      productId: json['productId'] as String,
      aisleId: json['aisleId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'aisleId': aisleId,
    };
  }

  @override
  List<Object?> get props => [productId, aisleId];
}

/// Model for an aisle with its associated products
class AisleWithProducts extends Equatable {
  final String id;
  final String storeSlug;
  final AisleType type;
  final Offset position;
  final int width;
  final int height;
  final List<ProductAisleAssociation> products;

  const AisleWithProducts({
    required this.id,
    required this.storeSlug,
    required this.type,
    required this.position,
    required this.width,
    required this.height,
    required this.products,
  });

  factory AisleWithProducts.fromJson(Map<String, dynamic> json) {
    return AisleWithProducts(
      id: json['id'] as String,
      storeSlug: json['storeSlug'] as String,
      type: AisleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AisleType.OTHER,
      ),
      position: Offset(
        (json['gridX'] as int).toDouble(),
        (json['gridY'] as int).toDouble(),
      ),
      width: json['width'] as int,
      height: json['height'] as int,
      products: (json['ProductInAisle'] as List<dynamic>)
          .map((item) => ProductAisleAssociation.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeSlug': storeSlug,
      'type': type.name,
      'gridX': position.dx.toInt(),
      'gridY': position.dy.toInt(),
      'width': width,
      'height': height,
      'ProductInAisle': products.map((p) => p.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, storeSlug, type, position, width, height, products];
}
