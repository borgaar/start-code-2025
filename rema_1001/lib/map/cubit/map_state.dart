part of 'map_cubit.dart';

sealed class MapState extends Equatable {
  const MapState();
}

final class MapInitial extends MapState {
  @override
  List<Object?> get props => [];
}

final class MapLoaded extends MapState {
  final MapModel map;
  final int currentStep;
  final List<ShoppingListAisleGroup> aisleGroups;

  const MapLoaded({
    required this.map,
    required this.currentStep,
    required this.aisleGroups,
  });

  @override
  List<Object?> get props => [map, currentStep, aisleGroups];
}

final class ShoppingListAisleGroup extends Equatable {
  final String aisleId;
  final String aisleType;
  final List<ShoppingListAisleItem> items;

  String get aisleName {
    return switch (aisleType) {
      "OBSTACLE" => "",
      "FREEZER" => "Frysevarer",
      "DRINKS" => "Drikkevarer",
      "PANTRY" => "Tørrvarer",
      "SWEETS" => "Søtsaker",
      "CHEESE" => "Ost",
      "MEAT" => "Kjøtt",
      "DAIRY" => "Meieri",
      "FRIDGE" => "Kjøledisk",
      "FRUIT" => "Frukt",
      "VEGETABLES" => "Grønnsaker",
      "BAKERY" => "Bakeri",
      "OTHER" => "Annet",
      _ => "Ukjent",
    };
  }

  const ShoppingListAisleGroup({
    required this.aisleId,
    required this.aisleType,
    required this.items,
  });

  @override
  List<Object?> get props => [aisleId, items];

  ShoppingListAisleGroup copyWith({
    String? aisleId,
    String? aisleType,
    List<ShoppingListAisleItem>? items,
  }) {
    return ShoppingListAisleGroup(
      items: items ?? this.items,
      aisleId: aisleId ?? this.aisleId,
      aisleType: aisleType ?? this.aisleType,
    );
  }
}

final class ShoppingListAisleItem extends Equatable {
  final String itemId;
  final String itemName;
  final int quantity;
  final bool isChecked;
  final Product product;

  const ShoppingListAisleItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.isChecked,
    required this.product,
  });

  ShoppingListAisleItem copyWith({
    String? itemId,
    String? itemName,
    int? quantity,
    bool? isChecked,
    Product? product,
  }) {
    return ShoppingListAisleItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      product: product ?? this.product,
    );
  }

  @override
  List<Object?> get props => [itemId, itemName, quantity, isChecked, product];
}

final class MapPathfindingLoaded extends MapLoaded {
  final List<Waypoint> path;
  final int currentWaypointIndex;

  const MapPathfindingLoaded({
    required super.map,
    required this.currentWaypointIndex,
    required this.path,
    required super.currentStep,
    required super.aisleGroups,
  });

  @override
  List<Object?> get props => [...super.props, path, currentWaypointIndex];
}

final class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
