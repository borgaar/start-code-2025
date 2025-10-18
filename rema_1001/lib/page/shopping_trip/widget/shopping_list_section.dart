import 'package:flutter/material.dart';
import 'package:rema_1001/data/models/shopping_list.dart';

class ShoppingListSection extends StatelessWidget {
  final List<ShoppingList> shoppingLists;
  final Function(String shoppingListId) onShoppingListSelected;

  const ShoppingListSection({
    required this.shoppingLists,
    required this.onShoppingListSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shoppingLists.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingen handlelister tilgjengelig',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...shoppingLists.map((list) {
              // Prefer API-provided counts, fallback to calculating from items
              final totalItems = list.totalItems ?? list.items.length;
              final checkedItems =
                  list.checkedItems ??
                  list.items.where((item) => item.checked).length;

              return ListTile(
                tileColor: Theme.of(context).listTileTheme.tileColor,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.list_alt,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  list.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '$checkedItems/$totalItems varer',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => onShoppingListSelected(list.id),
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
