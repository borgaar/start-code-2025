import 'package:flutter/material.dart';

class ShoppingListsEmptyState extends StatelessWidget {
  const ShoppingListsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[500]),
          const SizedBox(height: 16),
          Text(
            'Ingen handlelister ennå',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Opprett din første liste for å komme i gang',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
