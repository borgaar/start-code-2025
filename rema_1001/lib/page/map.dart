import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rema_1001/map/map.dart';
import 'package:rema_1001/map/map_painter.dart';
import 'package:rema_1001/router/route_names.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: MapPainter(
                  map: Map(
                    walkPoints: const [],
                    aisles: const [
                      // Top-left counter/checkout area
                      Aisle(topLeft: Offset(10, 4), width: 15, height: 6),

                      // Top-right three small blocks
                      Aisle(topLeft: Offset(31, 4), width: 5, height: 5),
                      Aisle(topLeft: Offset(38, 4), width: 5, height: 5),
                      Aisle(topLeft: Offset(45, 4), width: 5, height: 5),

                      // Upper-middle left rectangle
                      Aisle(topLeft: Offset(10, 17), width: 18, height: 7),

                      // Upper-middle center rectangle
                      Aisle(topLeft: Offset(31, 17), width: 12, height: 7),

                      // Right tall vertical rectangle
                      Aisle(topLeft: Offset(46, 17), width: 4, height: 18),

                      // Lower-middle left rectangle
                      Aisle(topLeft: Offset(10, 27), width: 18, height: 7),

                      // Lower-middle center rectangle
                      Aisle(topLeft: Offset(31, 27), width: 12, height: 7),

                      // Bottom three circles
                      Aisle(topLeft: Offset(23, 42), width: 5, height: 5),
                      Aisle(topLeft: Offset(31, 42), width: 3, height: 3),
                      Aisle(topLeft: Offset(38, 42), width: 5, height: 5),

                      // Bottom large rectangle
                      Aisle(topLeft: Offset(17, 50), width: 30, height: 9),

                      // Borders
                      Aisle(topLeft: Offset(0, 0), width: 8, height: 64),
                      Aisle(topLeft: Offset(0, 0), width: 64, height: 8),
                      Aisle(topLeft: Offset(56, 0), width: 8, height: 64),
                    ],
                  ),
                ),
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
}
