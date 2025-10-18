import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/data/models/shopping_list.dart';
import 'package:rema_1001/page/shopping_lists/cubit/shopping_lists_cubit.dart';
import 'package:rema_1001/router/route_names.dart';

class ShoppingListTile extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onRename;

  const ShoppingListTile({
    super.key,
    required this.list,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    // Prefer API-provided counts, fallback to calculating from items
    final itemCount = list.totalItems ?? list.items.length;
    final checkedCount =
        list.checkedItems ?? list.items.where((item) => item.checked).length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key(list.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Delete Shopping List'),
              content: Text('Are you sure you want to delete "${list.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          context.read<ShoppingListsCubit>().deleteShoppingList(list.id);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${list.name} deleted')));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.shopping_basket,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(list.name),
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
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // context.push('/lists/${list.id}');
              context.pushNamed(
                RouteNames.shoppingListDetail,
                pathParameters: {'id': list.id},
              );
            },
            onLongPress: onRename,
          ),
        ),
      ),
    );
  }
}
