import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/models/shopping_list_item.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/cubit/shopping_list_detail_cubit.dart';
import 'package:rema_1001/page/shopping_lists/shopping_list_detail_page/cubit/shopping_list_detail_state.dart';

class ShoppingListItemTile extends StatelessWidget {
  final ShoppingListItem item;

  const ShoppingListItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _handleDelete(context),
        background: _buildDismissBackground(),
        child: _buildContent(context),
      ),
    );
  }

  void _handleDelete(BuildContext context) {
    context.read<ShoppingListDetailCubit>().removeItem(item.id);
  }

  Widget _buildDismissBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: _buildCheckbox(context),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: _buildQuantityControls(context),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Checkbox(
      value: item.checked,
      onChanged: (_) => _handleToggleChecked(context),
    );
  }

  void _handleToggleChecked(BuildContext context) {
    context.read<ShoppingListDetailCubit>().toggleItemChecked(
      item.id,
      item.checked,
    );
  }

  Widget _buildTitle() {
    return Text(
      _formatTitle(item.product.name),
      style: TextStyle(
        decoration: item.checked ? TextDecoration.lineThrough : null,
        color: item.checked ? Colors.grey[600] : null,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPrice(),
        if (item.product.allergens.isNotEmpty) _buildAllergens(),
      ],
    );
  }

  Widget _buildPrice() {
    return Text(
      '${item.product.price.round()} kr',
      style: TextStyle(
        color: item.checked ? Colors.grey[600] : Colors.grey[400],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAllergens() {
    return Text(
      'Allergener: ${item.product.allergens.join(", ")}',
      style: TextStyle(color: Colors.orange[400], fontSize: 12),
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQuantityButton(
          context: context,
          icon: Icons.remove_circle_outline,
          onPressed: item.quantity > 1
              ? () => _handleQuantityChange(context, item.quantity - 1)
              : null,
        ),
        _buildQuantityDisplay(),
        _buildQuantityButton(
          context: context,
          icon: Icons.add_circle_outline,
          onPressed: () => _handleQuantityChange(context, item.quantity + 1),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton(icon: Icon(icon), onPressed: onPressed, iconSize: 20);
  }

  Widget _buildQuantityDisplay() {
    return BlocBuilder<ShoppingListDetailCubit, ShoppingListDetailState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: state is ShoppingListDetailLoading
                ? Colors.grey
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${item.quantity}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  void _handleQuantityChange(BuildContext context, int newQuantity) {
    context.read<ShoppingListDetailCubit>().updateItemQuantity(
      item.id,
      newQuantity,
    );
  }
}

String _formatTitle(String name) {
  final regex = RegExp(r'^(.*?)(\s*\d.*)?$');
  final match = regex.firstMatch(name);
  if (match != null) {
    return match.group(1)!.trim();
  }
  return name;
}
