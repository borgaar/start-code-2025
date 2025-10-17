import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/data/repositories/store_repository.dart';
import 'package:rema_1001/page/shopping_trip/store_selection/cubit/store_selection_cubit.dart';
import 'package:rema_1001/page/shopping_trip/store_selection/cubit/store_selection_state.dart';
import 'package:rema_1001/router/route_names.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StoreSelectionCubit(context.read<StoreRepository>())..loadStores(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Shopping Trips')),
        body: BlocConsumer<StoreSelectionCubit, StoreSelectionState>(
          listener: (context, state) {
            if (state is StoreSelectionError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final stores = state is StoreSelectionInProgress
                ? state.stores
                : [];

            return Skeletonizer(
              enabled: state is StoreSelectionLoading,
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
                          _buildTripCard(
                            context,
                            'Rema 1001 Sentrum',
                            'Weekly shopping - 45 items',
                            Icons.store,
                          ),
                          const SizedBox(height: 12),
                          _buildTripCard(
                            context,
                            'Rema 1001 Vest',
                            'Quick shopping - 12 items',
                            Icons.store,
                          ),
                          const SizedBox(height: 12),
                          _buildTripCard(
                            context,
                            'Rema 1001 Øst',
                            'Party supplies - 28 items',
                            Icons.store,
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.store, size: 40),
                              title: Text(
                                store.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                context.goNamed(
                                  RouteNames.shoppingListSelection,
                                  pathParameters: {'storeSlug': store.slug},
                                );
                              },
                            ),
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

  Widget _buildTripCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
