import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/models/product.dart';
import 'package:rema_1001/data/repositories/product_repository.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/add_item/cubit/add_item_cubit.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/add_item/cubit/add_item_state.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/add_item/widget/empty_state_widget.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/add_item/widget/search_product_list_tile.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/add_item/widget/quantity_dialog.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/add_item/widget/search_bar_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AddItemCubit(context.read<ProductRepository>())..loadProducts(),
      child: const _AddItemView(),
    );
  }
}

class _AddItemView extends StatefulWidget {
  const _AddItemView();

  @override
  State<_AddItemView> createState() => _AddItemViewState();
}

class _AddItemViewState extends State<_AddItemView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<AddItemCubit>().filterProducts(query);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<AddItemCubit>().clearSearch();
  }

  Future<void> _showQuantityDialog(Product product) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => QuantityDialog(product: product),
    );

    if (result != null && mounted) {
      // Return the product and quantity to the previous page
      Navigator.of(
        context,
      ).pop({'productId': product.productId, 'quantity': result});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: BlocBuilder<AddItemCubit, AddItemState>(
            builder: (context, state) {
              final hasQuery =
                  state is AddItemInProgress && state.searchQuery.isNotEmpty;
              return ProductSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
                hasQuery: hasQuery,
              );
            },
          ),
        ),
      ),
      body: BlocConsumer<AddItemCubit, AddItemState>(
        listener: (context, state) {
          if (state is AddItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<AddItemCubit>().loadProducts();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddItemInProgress) {
            final products = state.filteredProducts;
            final searchQuery = state.searchQuery;

            if (products.isEmpty && state is! AddItemLoading) {
              return AddItemEmptyState(isSearching: searchQuery.isNotEmpty);
            }

            return Skeletonizer(
              enabled: state is AddItemLoading,
              child: RefreshIndicator(
                onRefresh: () => context.read<AddItemCubit>().loadProducts(),
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return SearchProductListTile(
                      product: product,
                      onTap: () => _showQuantityDialog(product),
                    );
                  },
                ),
              ),
            );
          }

          if (state is AddItemInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
