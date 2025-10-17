import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/models/shopping_list.dart';
import 'package:rema_1001/data/models/store.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'package:rema_1001/data/repositories/store_repository.dart';
import 'package:rema_1001/page/shopping_trip/cubit/shopping_trip_cubit.dart';
import 'package:rema_1001/page/shopping_trip/cubit/shopping_trip_state.dart';
import 'package:rema_1001/page/shopping_trip/widget/expandable_store_card.dart';
import 'package:rema_1001/page/shopping_trip/widget/recent_trip_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String? _expandedStoreSlug;

  void _toggleStore(String storeSlug) {
    setState(() {
      if (_expandedStoreSlug == storeSlug) {
        _expandedStoreSlug = null;
      } else {
        _expandedStoreSlug = storeSlug;
      }
    });
  }

  void _onShoppingListSelected(String storeSlug, String shoppingListId) {
    // TODO: Implement the actual shopping trip logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting trip at store: $storeSlug with list: $shoppingListId',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShoppingTripCubit(
        context.read<StoreRepository>(),
        context.read<ShoppingListRepository>(),
      )..loadData(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Shopping Trips')),
        body: BlocConsumer<ShoppingTripCubit, ShoppingTripState>(
          listener: (context, state) {
            if (state is ShoppingTripError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final stores = state is ShoppingTripLoaded
                ? state.stores
                : <Store>[];
            final shoppingLists = state is ShoppingTripLoaded
                ? state.shoppingLists
                : <ShoppingList>[];

            return Skeletonizer(
              enabled: state is ShoppingTripLoading,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Trips',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const RecentTripCard(
                            title: 'Rema 1001 Sentrum',
                            subtitle: 'Weekly shopping - 45 items',
                            icon: Icons.store,
                          ),
                          const SizedBox(height: 12),
                          const RecentTripCard(
                            title: 'Rema 1001 Vest',
                            subtitle: 'Quick shopping - 12 items',
                            icon: Icons.store,
                          ),
                          const SizedBox(height: 12),
                          const RecentTripCard(
                            title: 'Rema 1001 Øst',
                            subtitle: 'Party supplies - 28 items',
                            icon: Icons.store,
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text(
                            'Select a Store',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final store = stores[index];
                        final isExpanded = _expandedStoreSlug == store.slug;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ExpandableStoreCard(
                            store: store,
                            isExpanded: isExpanded,
                            shoppingLists: shoppingLists,
                            onToggle: () => _toggleStore(store.slug),
                            onShoppingListSelected: _onShoppingListSelected,
                          ),
                        );
                      }, childCount: stores.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
