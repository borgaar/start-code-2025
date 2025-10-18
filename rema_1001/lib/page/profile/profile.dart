import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/constants/assets.dart';
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
            CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF4A9EFF),
              backgroundImage: AssetImage(Assets.oddReitan),
            ),
            const SizedBox(height: 20),
            const Text(
              'Odd Reitan',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'odd.reitan@reitan.no',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
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
                  _buildProfileOption(
                    Icons.favorite,
                    'Favorites',
                    'View your favorite items',
                  ),
                  _buildProfileOption(
                    Icons.payment,
                    'Payment Methods',
                    'Manage your payment options',
                  ),
                  _buildProfileOption(
                    Icons.settings,
                    'Settings',
                    'App preferences and settings',
                    () => context.pushNamed(RouteNames.settings),
                  ),
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

  Widget _buildProfileOption(
    IconData icon,
    String title,
    String subtitle, [
    VoidCallback? onTap,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
