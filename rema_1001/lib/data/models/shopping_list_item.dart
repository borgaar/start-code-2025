import 'package:equatable/equatable.dart';
import 'product.dart';

class ShoppingListItem extends Equatable {
  final String id;
  final String shoppingListId;
  final String productId;
  final int quantity;
  final bool checked;
  final Product product;

  const ShoppingListItem({
    required this.id,
    required this.shoppingListId,
    required this.productId,
    required this.quantity,
    required this.checked,
    required this.product,
  });

  factory ShoppingListItem.mock({id = 0}) {
    return ShoppingListItem(
      id: 'item_$id',
      shoppingListId: 'list_0',
      productId: 'prod_id_$id',
      quantity: (id % 5) + 1,
      checked: false,
      product: Product(
        productId: 'prod_id_$id',
        gtin: 'gtin_$id',
        name: 'Product $id',
        description: 'Description for product $id',
        price: (id + 1) * 10.0,
        pricePerUnit: 10.0,
        unit: 'kg',
        allergens: id % 3 == 0 ? ['milk'] : [],
        carbonFootprintGram: (id + 1) * 100.0,
        organic: id % 2 == 0,
      ),
    );
  }

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] as String,
      shoppingListId: json['shoppingListId'] as String,
      productId: json['productId'] as String,
      quantity: (json['quantity'] as int?) ?? 1, // Default to 1 if not provided
      checked: json['checked'] as bool,
      // Handle both 'product' and 'products' (API inconsistency)
      product: Product.fromJson(
        (json['product'] ?? json['products']) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shoppingListId': shoppingListId,
      'productId': productId,
      'quantity': quantity,
      'checked': checked,
      'product': product.toJson(),
    };
  }

  ShoppingListItem copyWith({
    String? id,
    String? shoppingListId,
    String? productId,
    int? quantity,
    bool? checked,
    Product? product,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      checked: checked ?? this.checked,
      product: product ?? this.product,
    );
  }

  @override
  List<Object?> get props => [
    id,
    shoppingListId,
    productId,
    quantity,
    checked,
    product,
  ];
}
