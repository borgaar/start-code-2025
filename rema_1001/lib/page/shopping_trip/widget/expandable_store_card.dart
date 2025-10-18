import 'package:flutter/material.dart';
import 'package:rema_1001/data/models/shopping_list.dart';
import 'package:rema_1001/data/models/store.dart';
import 'package:rema_1001/page/shopping_trip/widget/shopping_list_section.dart';

class ExpandableStoreCard extends StatelessWidget {
  final Store store;
  final bool isExpanded;
  final List<ShoppingList> shoppingLists;
  final VoidCallback onToggle;
  final Function(String storeSlug, String shoppingListId)
  onShoppingListSelected;

  const ExpandableStoreCard({
    required this.store,
    required this.isExpanded,
    required this.shoppingLists,
    required this.onToggle,
    required this.onShoppingListSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).listTileTheme.tileColor,
      child: Column(
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: isExpanded
                  ? BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    )
                  : BorderRadius.all(Radius.circular(12.0)),
            ),
            leading: const Icon(Icons.store, size: 40),
            title: Text(
              store.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: onToggle,
          ),
          if (isExpanded)
            ShoppingListSection(
              shoppingLists: shoppingLists,
              onShoppingListSelected: (shoppingListId) {
                onShoppingListSelected(store.slug, shoppingListId);
              },
            ),
        ],
      ),
    );
  }
}
