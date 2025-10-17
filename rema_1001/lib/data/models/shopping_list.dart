import 'package:equatable/equatable.dart';
import 'shopping_list_item.dart';

class ShoppingList extends Equatable {
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;
  final List<ShoppingListItem> items;

  const ShoppingList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  factory ShoppingList.mock({id = 0}) {
    final now = DateTime.now().toIso8601String();
    return ShoppingList(
      id: 'list_$id',
      name: 'Shopping List $id',
      createdAt: now,
      updatedAt: now,
      items: List.generate(5, (index) => ShoppingListItem.mock(id: index)),
    );
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      items: json['items'] != null
          ? (json['items'] as List)
                .map(
                  (item) =>
                      ShoppingListItem.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  ShoppingList copyWith({
    String? id,
    String? name,
    String? createdAt,
    String? updatedAt,
    List<ShoppingListItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, items];
}
