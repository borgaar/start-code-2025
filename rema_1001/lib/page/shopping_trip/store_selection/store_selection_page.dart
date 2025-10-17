import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/data/repositories/store_repository.dart';
import 'package:rema_1001/page/shopping_trip/store_selection/cubit/store_selection_cubit.dart';
import 'package:rema_1001/page/shopping_trip/store_selection/cubit/store_selection_state.dart';
import 'package:rema_1001/page/shopping_trip/store_selection/widget/empty_state_widget.dart';
import 'package:rema_1001/page/shopping_trip/store_selection/widget/store_list_tile.dart';
import 'package:rema_1001/router/route_names.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StoreSelectionPage extends StatelessWidget {
  const StoreSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StoreSelectionCubit(context.read<StoreRepository>())..loadStores(),
      child: const _StoreSelectionView(),
    );
  }
}

class _StoreSelectionView extends StatelessWidget {
  const _StoreSelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StoreSelectionCubit>().refresh();
            },
          ),
        ],
      ),
      body: BlocConsumer<StoreSelectionCubit, StoreSelectionState>(
        listener: (context, state) {
          if (state is StoreSelectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<StoreSelectionCubit>().loadStores();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StoreSelectionInProgress) {
            final stores = state.stores;

            if (stores.isEmpty && state is! StoreSelectionLoading) {
              return const StoreSelectionEmptyState();
            }

            return Skeletonizer(
              enabled: state is StoreSelectionLoading,
              child: RefreshIndicator(
                onRefresh: () => context.read<StoreSelectionCubit>().refresh(),
                child: ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return StoreListTile(
                      store: store,
                      onTap: () {
                        context.pushNamed(
                          RouteNames.shoppingListSelection,
                          pathParameters: {'storeSlug': store.slug},
                        );
                      },
                    );
                  },
                ),
              ),
            );
          }

          if (state is StoreSelectionInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
