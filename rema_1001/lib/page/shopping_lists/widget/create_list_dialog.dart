import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/page/shopping_lists/cubit/shopping_lists_cubit.dart';

class CreateListDialog extends StatelessWidget {
  const CreateListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text('Opprett handleliste'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Listenavn',
          hintText: 'f.eks., Ukeshandel',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            context.read<ShoppingListsCubit>().createShoppingList(value.trim());
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Avbryt'),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              context.read<ShoppingListsCubit>().createShoppingList(name);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Opprett'),
        ),
      ],
    );
  }
}
