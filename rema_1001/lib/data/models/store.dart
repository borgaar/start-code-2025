import 'package:equatable/equatable.dart';
import 'aisle.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Aisle> aisles;

  const Store({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.aisles = const [],
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      aisles: json['aisles'] != null
          ? (json['aisles'] as List)
                .map((aisle) => Aisle.fromJson(aisle as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'aisles': aisles.map((aisle) => aisle.toJson()).toList(),
    };
  }

  Store copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Aisle>? aisles,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aisles: aisles ?? this.aisles,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, aisles];
}
