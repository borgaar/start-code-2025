import 'package:flutter/material.dart';

class AddItemEmptyState extends StatelessWidget {
  final bool isSearching;

  const AddItemEmptyState({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No products found' : 'No products available',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[400]),
          ),
          if (isSearching) ...[
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}
