import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String productId;
  final String gtin;
  final String name;
  final String description;
  final double price;
  final double pricePerUnit;
  final double? discount;
  final String unit;
  final List<String> allergens;
  final double carbonFootprintGram;
  final bool organic;
  final String? updatedAt;
  final String? createdAt;

  const Product({
    required this.productId,
    required this.gtin,
    required this.name,
    required this.description,
    required this.price,
    required this.pricePerUnit,
    this.discount,
    required this.unit,
    required this.allergens,
    required this.carbonFootprintGram,
    required this.organic,
    this.updatedAt,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] as String,
      gtin: json['gtin'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      unit: json['unit'] as String,
      allergens:
          (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      carbonFootprintGram: (json['carbonFootprintGram'] as num).toDouble(),
      organic: json['organic'] as bool,
      updatedAt: json['updatedAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  factory Product.mock({int id = 0}) {
    final productNames = [
      'Organic Bananas',
      'Whole Milk',
      'Sourdough Bread',
      'Free Range Eggs',
      'Cheddar Cheese',
      'Fresh Salmon',
      'Cherry Tomatoes',
      'Avocados',
      'Greek Yogurt',
      'Olive Oil',
    ];

    final descriptions = [
      'Fresh and ripe',
      'Full fat 3.5%',
      'Freshly baked',
      'Pack of 12',
      'Aged 12 months',
      'Wild caught',
      'Sweet and juicy',
      'Ready to eat',
      'Low fat 2%',
      'Extra virgin',
    ];

    final units = ['kg', 'l', 'pcs', 'g'];

    return Product(
      productId: 'PROD-${1000 + id}',
      gtin: '${5000000000000 + id}',
      name: productNames[id % productNames.length],
      description: descriptions[id % descriptions.length],
      price: 15.0 + (id % 10) * 5.0,
      pricePerUnit: 5.0 + (id % 5) * 2.5,
      unit: units[id % units.length],
      allergens: id % 3 == 0
          ? ['milk', 'lactose']
          : id % 5 == 0
          ? ['gluten']
          : [],
      carbonFootprintGram: 50.0 + (id % 8) * 25.0,
      organic: id % 2 == 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'gtin': gtin,
      'name': name,
      'description': description,
      'price': price,
      'pricePerUnit': pricePerUnit,
      'discount': discount,
      'unit': unit,
      'allergens': allergens,
      'carbonFootprintGram': carbonFootprintGram,
      'organic': organic,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
    productId,
    gtin,
    name,
    description,
    price,
    pricePerUnit,
    discount,
    unit,
    allergens,
    carbonFootprintGram,
    organic,
  ];
}
