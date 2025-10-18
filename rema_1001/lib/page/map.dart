import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/map/cubit/map_cubit.dart';
import 'package:rema_1001/map/map.dart';
import 'package:rema_1001/router/route_names.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MapCubit(context.read(), context.read(), context.read())..intialize(),
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Shopping Lists',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              MapWidget(),
              const SizedBox(height: 16),
              Center(
                child: Builder(
                  builder: (context) {
                    return Row(
                      children: [
                        ElevatedButton(
                          onPressed: context.read<MapCubit>().next,
                          child: const Text('Next'),
                        ),
                        ElevatedButton(
                          onPressed: context.read<MapCubit>().intialize,
                          child: const Text('Refresh'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
