import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'package:rema_1001/page/shopping_trip/shopping_list_selection/cubit/shopping_list_selection_cubit.dart';
import 'package:rema_1001/page/shopping_trip/shopping_list_selection/cubit/shopping_list_selection_state.dart';
import 'package:rema_1001/page/shopping_trip/shopping_list_selection/widget/empty_state_widget.dart';
import 'package:rema_1001/page/shopping_trip/shopping_list_selection/widget/shopping_list_selection_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ShoppingListSelectionPage extends StatelessWidget {
  final String storeSlug;

  const ShoppingListSelectionPage({super.key, required this.storeSlug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShoppingListSelectionCubit(
        context.read<ShoppingListRepository>(),
        storeSlug,
      )..loadShoppingLists(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Shopping List'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ShoppingListSelectionCubit>().refresh();
              },
            ),
          ],
        ),
        body: BlocConsumer<ShoppingListSelectionCubit, ShoppingListSelectionState>(
          listener: (context, state) {
            if (state is ShoppingListSelectionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      context
                          .read<ShoppingListSelectionCubit>()
                          .loadShoppingLists();
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ShoppingListSelectionInProgress) {
              final shoppingLists = state.shoppingLists;

              if (shoppingLists.isEmpty &&
                  state is! ShoppingListSelectionLoading) {
                return const ShoppingListSelectionEmptyState();
              }

              return Skeletonizer(
                enabled: state is ShoppingListSelectionLoading,
                child: RefreshIndicator(
                  onRefresh: () =>
                      context.read<ShoppingListSelectionCubit>().refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: shoppingLists.length,
                    itemBuilder: (context, index) {
                      final shoppingList = shoppingLists[index];
                      return ShoppingListSelectionTile(
                        shoppingList: shoppingList,
                        onTap: () {
                          debugPrint(
                            'Store: ${state.storeSlug}, Shopping List: ${shoppingList.id}',
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selected: ${shoppingList.name} for store ${state.storeSlug}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            }

            if (state is ShoppingListSelectionInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }
}
