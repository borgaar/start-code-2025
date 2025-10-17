import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/models/shopping_list_item.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/cubit/shopping_list_detail_cubit.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/cubit/shopping_list_detail_state.dart';

class ShoppingListItemTile extends StatelessWidget {
  final ShoppingListItem item;

  const ShoppingListItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<ShoppingListDetailCubit>().removeItem(item.id);
      },
      child: ListTile(
        leading: Checkbox(
          value: item.checked,
          onChanged: (value) {
            context.read<ShoppingListDetailCubit>().toggleItemChecked(
              item.id,
              item.checked,
            );
          },
        ),
        title: Text(
          product.name,
          style: TextStyle(
            decoration: item.checked ? TextDecoration.lineThrough : null,
            color: item.checked ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${product.price.toStringAsFixed(2)} kr',
              style: TextStyle(
                color: item.checked ? Colors.grey[600] : Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (product.allergens.isNotEmpty)
              Text(
                'Allergens: ${product.allergens.join(", ")}',
                style: TextStyle(color: Colors.orange[400], fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: item.quantity > 1
                  ? () {
                      context
                          .read<ShoppingListDetailCubit>()
                          .updateItemQuantity(item.id, item.quantity - 1);
                    }
                  : null,
              iconSize: 20,
            ),
            BlocBuilder<ShoppingListDetailCubit, ShoppingListDetailState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: state is ShoppingListDetailLoading
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                context.read<ShoppingListDetailCubit>().updateItemQuantity(
                  item.id,
                  item.quantity + 1,
                );
              },
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
