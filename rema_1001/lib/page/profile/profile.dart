import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/constants/assets.dart';
import 'package:rema_1001/router/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 3),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF4A9EFF),
                    backgroundImage: AssetImage(Assets.oddReitan),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Odd Reitan',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'odd@reitan.no',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(
                    Icons.shopping_bag,
                    'Mine bestillinger',
                    'Se bestillingshistorikken din',
                  ),
                  _buildProfileOption(
                    Icons.favorite,
                    'Favoritter',
                    'Se favorittvarene dine',
                  ),
                  _buildProfileOption(
                    Icons.payment,
                    'Betalingsmetoder',
                    'Administrer betalingsalternativene dine',
                  ),
                  _buildProfileOption(
                    Icons.settings,
                    'Innstillinger',
                    'Appinnstillinger og preferanser',
                    () => context.pushNamed(RouteNames.settings),
                  ),
                  _buildProfileOption(
                    Icons.help_outline,
                    'Hjelp og støtte',
                    'Få hjelp med kontoen din',
                  ),
                ],
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
