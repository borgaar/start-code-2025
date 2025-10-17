import 'package:flutter/material.dart';
import 'package:rema_1001/data/models/shopping_list.dart';

class ShoppingListSelectionTile extends StatelessWidget {
  final ShoppingList shoppingList;
  final VoidCallback onTap;

  const ShoppingListSelectionTile({
    super.key,
    required this.shoppingList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = shoppingList.items.length;
    final checkedCount = shoppingList.items
        .where((item) => item.checked)
        .length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.shopping_basket,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(shoppingList.name),
        subtitle: itemCount > 0
            ? Text(
                '$checkedCount/$itemCount items checked',
                style: TextStyle(color: Colors.grey[400]),
              )
            : Text(
                'Empty list',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (itemCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$itemCount',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
