import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/data/models/shopping_list.dart';
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
      appBar: _buildAppBar(),
      body: BlocConsumer<ShoppingListDetailCubit, ShoppingListDetailState>(
        listener: _handleStateChange,
        builder: _buildBody,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildAddButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: BlocBuilder<ShoppingListDetailCubit, ShoppingListDetailState>(
        builder: (context, state) {
          if (state is ShoppingListDetailInProgress) {
            return Skeletonizer(
              enabled: state is ShoppingListDetailLoading,
              child: Text(state.shoppingList.name),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleStateChange(BuildContext context, ShoppingListDetailState state) {
    if (state is ShoppingListDetailError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Prøv igjen',
            textColor: Colors.white,
            onPressed: () {
              context.read<ShoppingListDetailCubit>().loadShoppingList();
            },
          ),
        ),
      );
    }
  }

  Widget _buildBody(BuildContext context, ShoppingListDetailState state) {
    if (state is! ShoppingListDetailInProgress) {
      return const Center(child: Text('Noe gikk galt'));
    }

    final isLoading = state is ShoppingListDetailLoading;
    final list = state.shoppingList;

    return Skeletonizer(
      enabled: isLoading,
      child: RefreshIndicator(
        onRefresh: () => context
            .read<ShoppingListDetailCubit>()
            .loadShoppingList(emitLoading: true),
        child: _ShoppingListContent(list: list),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _handleAddItem(context),
      icon: const Icon(Icons.add),
      label: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: const Text('Legg til vare'),
      ),
    );
  }

  Future<void> _handleAddItem(BuildContext context) async {
    final cubit = context.read<ShoppingListDetailCubit>();
    final result = await context.pushNamed(
      RouteNames.addItem,
      pathParameters: {'id': cubit.listId},
    );

    if (result != null && result is Map<String, dynamic> && context.mounted) {
      final productId = result['productId'] as String;
      final quantity = result['quantity'] as int;
      cubit.addItem(productId, quantity);
    }
  }
}

class _ShoppingListContent extends StatelessWidget {
  final ShoppingList list;

  const _ShoppingListContent({required this.list});

  @override
  Widget build(BuildContext context) {
    final uncheckedItems = list.items.where((item) => !item.checked).toList();
    final checkedItems = list.items.where((item) => item.checked).toList();

    return ListView(
      children: [
        ProgressCard(
          totalItems: list.items.length,
          checkedItems: checkedItems.length,
        ),
        if (uncheckedItems.isNotEmpty)
          _ItemSection(
            title: 'Å handle',
            items: uncheckedItems,
            titleColor: Colors.grey[400],
          ),
        if (checkedItems.isNotEmpty)
          _ItemSection(
            title: 'Fullført',
            items: checkedItems,
            titleColor: Colors.grey[500],
            topPadding: 16,
          ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }
}

class _ItemSection extends StatelessWidget {
  final String title;
  final List items;
  final Color? titleColor;
  final double topPadding;

  const _ItemSection({
    required this.title,
    required this.items,
    this.titleColor,
    this.topPadding = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => ShoppingListItemTile(item: item)),
      ],
    );
  }
}
