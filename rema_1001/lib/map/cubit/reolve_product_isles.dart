import 'package:rema_1001/data/models/aisle.dart' show Aisle;
import 'package:rema_1001/data/models/product_aisle_location.dart'
    show ProductAisleLocation;
import 'package:rema_1001/data/models/shopping_list.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';

List<ShoppingListAisleGroup> resolveProductIsles({
  required ShoppingList shoppingList,
  required List<Aisle> aisles,
}) {
  // Create a map of aisleId -> Aisle for quick lookup
  final aisleMap = {for (final aisle in aisles) aisle.id: aisle};

  // Create a map of productId -> aisleId from the shopping list's aisle locations
  final productToAisleMap = {
    for (final location in shoppingList.aisles ?? <ProductAisleLocation>[])
      location.productId: location.aisleId,
  };

  // Group items by aisle
  final Map<String, List<ShoppingListAisleItem>> aisleGroups = {};

  for (final item in shoppingList.items) {
    final aisleId = productToAisleMap[item.productId];

    // Skip items that don't have an aisle mapping
    if (aisleId == null) continue;

    final aisleItem = ShoppingListAisleItem(
      itemId: item.id,
      itemName: item.product.name,
      quantity: item.quantity,
      isChecked: item.checked,
      product: item.product,
    );

    aisleGroups.putIfAbsent(aisleId, () => []).add(aisleItem);
  }

  // Convert the grouped items into ShoppingListAisleGroup objects
  return aisleGroups.entries.map((entry) {
    final aisleId = entry.key;
    final items = entry.value;
    final aisle = aisleMap[aisleId];

    return ShoppingListAisleGroup(
      aisleId: aisleId,
      aisleType: aisle?.type.name ?? 'OTHER',
      items: items,
    );
  }).toList();
}
