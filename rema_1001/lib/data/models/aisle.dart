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
  final int gridX;
  final int gridY;
  final int width;
  final int height;

  const Aisle({
    required this.id,
    required this.storeSlug,
    required this.type,
    required this.gridX,
    required this.gridY,
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
      gridX: json['gridX'] as int,
      gridY: json['gridY'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeSlug': storeSlug,
      'type': type.name,
      'gridX': gridX,
      'gridY': gridY,
      'width': width,
      'height': height,
    };
  }

  Aisle copyWith({
    String? id,
    String? storeSlug,
    AisleType? type,
    int? gridX,
    int? gridY,
    int? width,
    int? height,
  }) {
    return Aisle(
      id: id ?? this.id,
      storeSlug: storeSlug ?? this.storeSlug,
      type: type ?? this.type,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [id, storeSlug, type, gridX, gridY, width, height];
}
