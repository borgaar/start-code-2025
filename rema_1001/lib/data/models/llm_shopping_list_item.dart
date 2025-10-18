import 'package:equatable/equatable.dart';

class LlmShoppingListItem extends Equatable {
  final String productId;
  final String name;
  final double quantity;
  final String unit;

  const LlmShoppingListItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory LlmShoppingListItem.fromJson(Map<String, dynamic> json) {
    return LlmShoppingListItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  @override
  List<Object?> get props => [
    productId,
    name,
    quantity,
    unit,
  ];
}

class LlmShoppingList extends Equatable {
  final String title;
  final List<LlmShoppingListItem> items;

  const LlmShoppingList({
    required this.title,
    required this.items,
  });

  factory LlmShoppingList.fromJson(Map<String, dynamic> json) {
    return LlmShoppingList(
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => LlmShoppingListItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [title, items];
}

class LlmShoppingListResponse extends Equatable {
  final List<LlmShoppingList> lists;

  const LlmShoppingListResponse({
    required this.lists,
  });

  factory LlmShoppingListResponse.fromJson(Map<String, dynamic> json) {
    return LlmShoppingListResponse(
      lists: (json['lists'] as List<dynamic>)
          .map((list) => LlmShoppingList.fromJson(list as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lists': lists.map((list) => list.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [lists];
}
