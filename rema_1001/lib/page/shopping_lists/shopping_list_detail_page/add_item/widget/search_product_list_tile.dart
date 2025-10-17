import 'package:flutter/material.dart';
import 'package:rema_1001/data/models/product.dart';

class SearchProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const SearchProductListTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.shopping_basket,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(product.name),
      subtitle: Text(
        '${product.price.toStringAsFixed(2)} kr',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.add_circle_outline),
      onTap: onTap,
    );
  }
}
