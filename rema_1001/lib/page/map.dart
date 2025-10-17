import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/router/route_names.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add new list functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Shopping Lists',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildListCard(
                    'Weekly Groceries',
                    '12 items',
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildListCard(
                    'Party Supplies',
                    '8 items',
                    Icons.celebration,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildListCard(
                    'Breakfast Items',
                    '5 items',
                    Icons.free_breakfast,
                    Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => context.goNamed(RouteNames.home),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(String title, String itemCount, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(itemCount),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
