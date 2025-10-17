import 'package:flutter/material.dart';
import 'package:rema_1001/data/models/product.dart';

class QuantityDialog extends StatefulWidget {
  final Product product;

  const QuantityDialog({super.key, required this.product});

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.product.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select quantity:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 32,
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_quantity),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
