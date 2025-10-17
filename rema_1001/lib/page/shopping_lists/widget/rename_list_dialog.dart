import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/page/shopping_lists/cubit/shopping_lists_cubit.dart';

class RenameListDialog extends StatelessWidget {
  final String listId;
  final String currentName;

  const RenameListDialog({
    super.key,
    required this.listId,
    required this.currentName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: currentName);

    return AlertDialog(
      title: const Text('Rename Shopping List'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'List Name',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty && value.trim() != currentName) {
            context.read<ShoppingListsCubit>().updateShoppingList(
              listId,
              value.trim(),
            );
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty && name != currentName) {
              context.read<ShoppingListsCubit>().updateShoppingList(
                listId,
                name,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
