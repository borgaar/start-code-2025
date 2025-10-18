import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'aisle.dart';

class Store extends Equatable {
  final String slug;
  final String name;
  final Offset entrance;
  final Offset exit;
  final String? createdAt;
  final String? updatedAt;
  final List<Aisle> aisles;

  const Store({
    required this.slug,
    required this.name,
    required this.entrance,
    required this.exit,
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
      entrance: Offset((id * 2).toDouble(), 0),
      exit: Offset((id * 2 + 10).toDouble(), 0),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      aisles: [],
    );
  }

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      slug: json['slug'] as String,
      name: json['name'] as String,
      entrance: Offset(
        (json['entranceX'] as int).toDouble(),
        (json['entranceY'] as int).toDouble(),
      ),
      exit: Offset(
        (json['exitX'] as int).toDouble(),
        (json['exitY'] as int).toDouble(),
      ),
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
      'entranceX': entrance.dx.toInt(),
      'entranceY': entrance.dy.toInt(),
      'exitX': exit.dx.toInt(),
      'exitY': exit.dy.toInt(),
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'aisles': aisles.map((aisle) => aisle.toJson()).toList(),
    };
  }

  Store copyWith({
    String? slug,
    String? name,
    Offset? entrance,
    Offset? exit,
    String? createdAt,
    String? updatedAt,
    List<Aisle>? aisles,
  }) {
    return Store(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      entrance: entrance ?? this.entrance,
      exit: exit ?? this.exit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aisles: aisles ?? this.aisles,
    );
  }

  @override
  List<Object?> get props => [slug, name, entrance, exit, createdAt, updatedAt, aisles];
}
