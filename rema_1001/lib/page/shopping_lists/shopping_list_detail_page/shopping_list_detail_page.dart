import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/cubit/shopping_list_detail_cubit.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/cubit/shopping_list_detail_state.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/widget/progress_card_widget.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/widget/shopping_list_item_tile.dart';
import 'package:rema_1001/router/route_names.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ShoppingListDetailPage extends StatelessWidget {
  final String listId;

  const ShoppingListDetailPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShoppingListDetailCubit(
        repository: context.read<ShoppingListRepository>(),
        listId: listId,
      )..loadShoppingList(emitLoading: true),
      child: const _ShoppingListDetailView(),
    );
  }
}

class _ShoppingListDetailView extends StatelessWidget {
  const _ShoppingListDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ShoppingListDetailCubit, ShoppingListDetailState>(
          builder: (context, state) {
            if (state is ShoppingListDetailInProgress) {
              return Skeletonizer(
                enabled: state is ShoppingListDetailLoading,
                child: Text(state.shoppingList.name),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
      body: BlocConsumer<ShoppingListDetailCubit, ShoppingListDetailState>(
        listener: (context, state) {
          if (state is ShoppingListDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ShoppingListDetailCubit>().loadShoppingList();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShoppingListDetailInProgress) {
            final list = state.shoppingList;

            // Separate checked and unchecked items
            final uncheckedItems = list.items
                .where((item) => !item.checked)
                .toList();
            final checkedItems = list.items
                .where((item) => item.checked)
                .toList();

            return Skeletonizer(
              enabled: state is ShoppingListDetailLoading,
              child: RefreshIndicator(
                onRefresh: () => context
                    .read<ShoppingListDetailCubit>()
                    .loadShoppingList(emitLoading: true),
                child: ListView(
                  children: [
                    // Summary card
                    ProgressCard(
                      totalItems: list.items.length,
                      checkedItems: checkedItems.length,
                    ),

                    // Unchecked items
                    if (uncheckedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          'To Buy',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      ...uncheckedItems.map(
                        (item) => ShoppingListItemTile(item: item),
                      ),
                    ],

                    // Checked items
                    if (checkedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Completed',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      ...checkedItems.map(
                        (item) => ShoppingListItemTile(item: item),
                      ),
                    ],

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final cubit = context.read<ShoppingListDetailCubit>();
          final result = await context.pushNamed(
            RouteNames.addItem,
            pathParameters: {'id': cubit.listId},
          );
          if (result != null &&
              result is Map<String, dynamic> &&
              context.mounted) {
            final productId = result['productId'] as String;
            final quantity = result['quantity'] as int;
            cubit.addItem(productId, quantity);
          }
        },
        icon: const Icon(Icons.add),
        label: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: const Text('Add Item'),
        ),
      ),
    );
  }
}
