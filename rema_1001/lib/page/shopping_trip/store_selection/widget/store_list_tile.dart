import 'package:flutter/material.dart';
import 'package:rema_1001/data/models/store.dart';

class StoreListTile extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const StoreListTile({super.key, required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.store,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(store.name),
      subtitle: Text(store.slug, style: TextStyle(color: Colors.grey[500])),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
