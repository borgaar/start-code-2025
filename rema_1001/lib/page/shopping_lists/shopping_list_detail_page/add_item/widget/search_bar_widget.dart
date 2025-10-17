import 'package:flutter/material.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasQuery
              ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
