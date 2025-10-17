import 'package:flutter/material.dart';
import 'package:rema_1001/map/map_painter.dart';
import 'package:rema_1001/map/model.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: MapPainter(
          map: MapModel(
            walkPoints: const [],
            aisles: [
              // Top-left counter/checkout area
              Aisle(
                topLeft: Offset(8, 6),
                width: 5,
                height: 2,
                status: AisleStatus.grey,
              ),
              Aisle(
                topLeft: Offset(6, 8),
                width: 2,
                height: 4,
                status: AisleStatus.grey,
              ),

              // Top-right three small blocks
              Aisle(
                topLeft: Offset(31, 4),
                width: 5,
                height: 4,
                status: AisleStatus.grey,
              ),
              Aisle(
                topLeft: Offset(38, 4),
                width: 5,
                height: 4,
                status: AisleStatus.grey,
              ),
              Aisle(
                topLeft: Offset(45, 4),
                width: 6,
                height: 4,
                status: AisleStatus.blinking,
              ),

              // Upper-middle left rectangle
              Aisle(topLeft: Offset(10, 17), width: 18, height: 7),

              // Upper-middle center rectangle
              Aisle(
                topLeft: Offset(31, 17),
                width: 12,
                height: 7,
                status: AisleStatus.grey,
              ),

              // Right tall vertical rectangle
              Aisle(topLeft: Offset(46, 17), width: 4, height: 18),

              // Lower-middle left rectangle
              Aisle(topLeft: Offset(10, 27), width: 18, height: 7),

              // Lower-middle center rectangle
              Aisle(topLeft: Offset(31, 27), width: 12, height: 7),

              // Bottom three circles
              Aisle(topLeft: Offset(23, 42), width: 5, height: 5),
              Aisle(topLeft: Offset(31, 42), width: 3, height: 3),
              Aisle(
                topLeft: Offset(38, 42),
                width: 5,
                height: 5,
                status: AisleStatus.white,
              ),

              // Bottom large rectangle
              // Aisle(topLeft: Offset(17, 50), width: 30, height: 9),

              // Borders
              Aisle(topLeft: Offset(0, 0), width: 8, height: 64),
              Aisle(topLeft: Offset(0, 0), width: 64, height: 8),
              Aisle(topLeft: Offset(56, 0), width: 8, height: 64),
            ],
          ),
        ),
      ),
    );
  }
}
