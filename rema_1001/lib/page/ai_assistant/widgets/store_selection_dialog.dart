import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/data/models/store.dart';
import 'package:rema_1001/data/repositories/store_repository.dart';

class StoreSelectionDialog extends StatefulWidget {
  const StoreSelectionDialog({super.key});

  @override
  State<StoreSelectionDialog> createState() => _StoreSelectionDialogState();
}

class _StoreSelectionDialogState extends State<StoreSelectionDialog> {
  List<Store>? stores;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    try {
      final storeRepo = context.read<StoreRepository>();
      final loadedStores = await storeRepo.getStores();
      setState(() {
        stores = loadedStores;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Kunne ikke laste butikker';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 29, 29, 29),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Velg butikk',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 94, 155, 245),
                  ),
                ),
              )
            else if (error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
            else if (stores != null && stores!.isNotEmpty)
              ...stores!.map(
                (store) => InkWell(
                  onTap: () => Navigator.of(context).pop(store.slug),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 40, 40, 40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.store,
                          color: Color.fromARGB(255, 94, 155, 245),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            store.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Ingen butikker tilgjengelig',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Avbryt',
                style: TextStyle(color: Color.fromARGB(255, 94, 155, 245)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
