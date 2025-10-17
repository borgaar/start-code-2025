import 'package:equatable/equatable.dart';

class ProductAisleLocation extends Equatable {
  final String productId;
  final String aisleId;

  const ProductAisleLocation({required this.productId, required this.aisleId});

  factory ProductAisleLocation.fromJson(Map<String, dynamic> json) {
    return ProductAisleLocation(
      productId: json['productId'] as String,
      aisleId: json['aisleId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'aisleId': aisleId};
  }

  @override
  List<Object?> get props => [productId, aisleId];
}
