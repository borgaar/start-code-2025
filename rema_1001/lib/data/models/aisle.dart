import 'dart:ui';
import 'package:equatable/equatable.dart';

enum AisleType {
  OBSTACLE,
  FREEZER,
  DRINKS,
  PANTRY,
  SWEETS,
  CHEESE,
  MEAT,
  DAIRY,
  FRIDGE,
  FRUIT,
  VEGETABLES,
  BAKERY,
  OTHER,
}

class Aisle extends Equatable {
  final String id;
  final String storeSlug;
  final AisleType type;
  final Offset position;
  final int width;
  final int height;

  const Aisle({
    required this.id,
    required this.storeSlug,
    required this.type,
    required this.position,
    required this.width,
    required this.height,
  });

  factory Aisle.fromJson(Map<String, dynamic> json) {
    return Aisle(
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
    };
  }

  Aisle copyWith({
    String? id,
    String? storeSlug,
    AisleType? type,
    Offset? position,
    int? width,
    int? height,
  }) {
    return Aisle(
      id: id ?? this.id,
      storeSlug: storeSlug ?? this.storeSlug,
      type: type ?? this.type,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [id, storeSlug, type, position, width, height];
}
