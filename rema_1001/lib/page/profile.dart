import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/router/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'john.doe@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(
                    Icons.shopping_bag,
                    'My Orders',
                    'View your order history',
                  ),
                  const Divider(),
                  _buildProfileOption(
                    Icons.favorite,
                    'Favorites',
                    'View your favorite items',
                  ),
                  const Divider(),
                  _buildProfileOption(
                    Icons.payment,
                    'Payment Methods',
                    'Manage your payment options',
                  ),
                  const Divider(),
                  _buildProfileOption(
                    Icons.settings,
                    'Settings',
                    'App preferences and settings',
                  ),
                  const Divider(),
                  _buildProfileOption(
                    Icons.help_outline,
                    'Help & Support',
                    'Get help with your account',
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

  Widget _buildProfileOption(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Navigate to specific settings
      },
    );
  }
}
