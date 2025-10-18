import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/models/product.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';

class ProductListTile extends StatelessWidget {
  const ProductListTile(this.item, this.aisleGroup, {super.key});

  final ShoppingListAisleItem item;
  final ShoppingListAisleGroup aisleGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTitle(item),
                  style: TextStyle(
                    fontSize: 14,
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.isChecked ? Colors.grey[600] : null,
                  ),
                ),
                Text(
                  "${item.product.pricePerUnit.round()} kr/${item.product.unit}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Checkbox(
            value: false,
            onChanged: (value) {
              context.read<MapCubit>().toggleCheckItem(item, aisleGroup);
            },
            fillColor: item.isChecked
                ? WidgetStatePropertyAll(Colors.white)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTitle(ShoppingListAisleItem item) {
  final regex = RegExp(r'^(.*?)(\s*\d.*)?$');
  final match = regex.firstMatch(item.itemName);
  String result = "";
  if (match != null) {
    result = match.group(1)!.trim();
  } else {
    result = item.itemName;
  }
  return "$result, ${item.quantity} ${item.product.unit}";
}
