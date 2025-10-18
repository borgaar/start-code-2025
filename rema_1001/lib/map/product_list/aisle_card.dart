import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';
import 'package:rema_1001/map/product_list/product_list_discounted_tile.dart';
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
                const SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ...aisle.items.mapIndexed((index, item) {
                          return ProductListTile(item, aisle);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              SizedBox(width: 16),
                              Expanded(
                                child: Divider(
                                  height: 2,
                                  color: Color(0xff2A2A2A),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Andre tilbud i hyllen",
                                style: TextStyle(
                                  color: Color(0xFF898989),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: "REMA",
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Divider(
                                  height: 2,
                                  color: Color(0xff2A2A2A),
                                ),
                              ),
                              SizedBox(width: 16),
                            ],
                          ),
                        ),
                        ...aisle.discountedItems.mapIndexed((index, item) {
                          return ProductListDiscountedTile(
                            item,
                            aisle,
                            index: index,
                          );
                        }),
                        SizedBox(height: 16),
                      ],
                    ),
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
