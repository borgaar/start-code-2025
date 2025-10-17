import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/router/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rema 1001')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Rema 1001',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(RouteNames.trips),
              icon: const Icon(Icons.map),
              label: const Text('View Trips'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(RouteNames.lists),
              icon: const Icon(Icons.list),
              label: const Text('Shopping Lists'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(RouteNames.profile),
              icon: const Icon(Icons.person),
              label: const Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
