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
}

final class ShoppingListAisleItem extends Equatable {
  final String itemId;
  final String itemName;
  final int quantity;
  final bool isChecked;

  const ShoppingListAisleItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.isChecked,
  });

  @override
  List<Object?> get props => [itemId, itemName, quantity, isChecked];
}

final class MapPathfindingLoaded extends MapLoaded {
  final List<Waypoint> path;

  const MapPathfindingLoaded({
    required super.map,
    required this.path,
    required super.currentStep,
    required super.aisleGroups,
  });

  @override
  List<Object?> get props => [...super.props, path, currentStep];
}
