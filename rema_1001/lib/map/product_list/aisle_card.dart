import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';
import 'package:rema_1001/map/product_list/product_list_tile.dart';

class AisleCard extends StatelessWidget {
  final ShoppingListAisleGroup aisle;

  const AisleCard(this.aisle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      aisle.aisleName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Checkbox(
                      value: false,
                      onChanged: null, // Read-only for now
                      fillColor: aisle.items.every((item) => item.isChecked)
                          ? WidgetStatePropertyAll(Colors.white)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: aisle.items.length,
                    itemBuilder: (context, index) {
                      final item = aisle.items[index];
                      return ProductListTile(item, aisle);
                    },
                  ),
                ),
              ],
            ),
            if (aisle.items.every((item) => item.isChecked))
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Next"),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                    onPressed: () {
                      final cubit = context.read<MapCubit>();
                      cubit.next();
                      cubit.carouselSliderController.nextPage();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
