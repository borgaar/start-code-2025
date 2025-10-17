import 'package:equatable/equatable.dart';
import 'aisle.dart';

class Store extends Equatable {
  final String slug;
  final String name;
  final String? createdAt;
  final String? updatedAt;
  final List<Aisle> aisles;

  const Store({
    required this.slug,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.aisles = const [],
  });

  factory Store.mock({int id = 0}) {
    final storeNames = [
      'Rema 1000 Elgeseter',
      'Rema 1000 City Syd',
      'Rema 1000 Trondheim Torg',
      'Rema 1000 Lade',
      'Rema 1000 Moholt',
    ];

    return Store(
      slug: 'store-${id + 1}',
      name: storeNames[id % storeNames.length],
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      aisles: [],
    );
  }

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      slug: json['slug'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      aisles: json['aisles'] != null
          ? (json['aisles'] as List)
                .map((aisle) => Aisle.fromJson(aisle as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'aisles': aisles.map((aisle) => aisle.toJson()).toList(),
    };
  }

  Store copyWith({
    String? slug,
    String? name,
    String? createdAt,
    String? updatedAt,
    List<Aisle>? aisles,
  }) {
    return Store(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aisles: aisles ?? this.aisles,
    );
  }

  @override
  List<Object?> get props => [slug, name, createdAt, updatedAt, aisles];
}
