import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';
import 'package:rema_1001/map/map.dart';
import 'package:rema_1001/map/product_list/product_list.dart';
import 'package:rema_1001/page/ai_assistant/widgets/store_selection_dialog.dart';
import 'package:rema_1001/router/route_names.dart';

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
          title: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 280;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isSmall) ...[
                    Image.asset(
                      "assets/images/rema-1000.png",
                      height: 17,
                    ).animate().fadeIn(),
                    SizedBox(width: 8),
                  ],

                  BlocBuilder<MapCubit, MapState>(
                    builder: (context, state) {
                      if (state is MapLoaded) {
                        return Text(state.storeName);
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  // SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      final storeSlug = await showDialog(
                        context: context,
                        builder: (context) => StoreSelectionDialog(),
                      );

                      if (storeSlug == null) return;

                      final slug = storeSlug as String;
                      if (!context.mounted) {
                        return;
                      }

                      GoRouter.of(context).pushReplacementNamed(
                        RouteNames.map,
                        pathParameters: {
                          'storeSlug': slug,
                          'shoppingListId': shoppingListId,
                        },
                      );
                    },
                    icon: Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              );
            },
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<MapCubit>().intialize();
                  },
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: const EdgeInsets.all(24.0), child: MapWidget()),
              BlocBuilder<MapCubit, MapState>(
                builder: (context, state) {
                  if (state is! MapPathfindingLoaded) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    child: ProductList(),
                  ).animate().fade().moveY(begin: 20, curve: Curves.easeOut);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
