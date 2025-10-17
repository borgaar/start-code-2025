import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/page/shopping_lists/cubit/shopping_lists_cubit.dart';
import 'package:rema_1001/page/shopping_lists/cubit/shopping_lists_state.dart';
import 'package:rema_1001/page/shopping_lists/widget/create_list_dialog.dart';
import 'package:rema_1001/page/shopping_lists/widget/empty_state_widget.dart';
import 'package:rema_1001/page/shopping_lists/widget/rename_list_dialog.dart';
import 'package:rema_1001/page/shopping_lists/widget/shopping_list_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ShoppingLists extends StatefulWidget {
  const ShoppingLists({super.key});

  @override
  State<ShoppingLists> createState() => _ShoppingListsState();
}

class _ShoppingListsState extends State<ShoppingLists> {
  @override
  void initState() {
    super.initState();
    // Load shopping lists when page is first opened
    context.read<ShoppingListsCubit>().loadShoppingLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Lists')),
      body: BlocConsumer<ShoppingListsCubit, ShoppingListsState>(
        listener: (context, state) {
          if (state is ShoppingListsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ShoppingListsCubit>().loadShoppingLists();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShoppingListsInProgress) {
            final shoppingLists = state.shoppingLists;

            if (shoppingLists.isEmpty && state is! ShoppingListsLoading) {
              return const ShoppingListsEmptyState();
            }

            return Skeletonizer(
              enabled: state is ShoppingListsLoading,
              child: RefreshIndicator(
                onRefresh: () => context
                    .read<ShoppingListsCubit>()
                    .loadShoppingLists(emitLoading: true),
                child: ListView.builder(
                  itemCount: shoppingLists.length,
                  itemBuilder: (context, index) {
                    final list = shoppingLists[index];
                    return ShoppingListTile(
                      list: list,
                      onRename: () => _showRenameDialog(list.id, list.name),
                    );
                  },
                ),
              ),
            );
          }

          if (state is ShoppingListsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('New List'),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateListDialog(),
    );
  }

  void _showRenameDialog(String listId, String currentName) {
    showDialog(
      context: context,
      builder: (context) =>
          RenameListDialog(listId: listId, currentName: currentName),
    );
  }
}
