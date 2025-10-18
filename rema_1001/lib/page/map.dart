import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';
import 'package:rema_1001/map/map.dart';
import 'package:rema_1001/map/product_list/product_list.dart';

class MapScreen extends StatelessWidget {
  final String storeSlug;
  final String shoppingListId;

  const MapScreen({
    super.key,
    required this.storeSlug,
    required this.shoppingListId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(
        storeSlug,
        shoppingListId,
        context.read(),
        context.read(),
        context.read(),
      )..intialize(),
      child: Scaffold(
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(16.0), child: MapWidget()),
            // Center(
            //   child: Builder(
            //     builder: (context) {
            //       return Row(
            //         children: [
            //           ElevatedButton(
            //             onPressed: context.read<MapCubit>().next,
            //             child: const Text('Next'),
            //           ),
            //           ElevatedButton(
            //             onPressed: context.read<MapCubit>().intialize,
            //             child: const Text('Refresh'),
            //           ),
            //         ],
            //       );
            //     },
            //   ),
            // ),
            Expanded(child: ProductList()),
          ],
        ),
      ),
    );
  }
}
