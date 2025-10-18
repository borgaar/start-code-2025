import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:rema_1001/map/pathfinding/calculate_path.dart';
import 'package:rema_1001/map/pathfinding/pathfinding_aisle.dart';

/// Parameters for the path calculation that can be sent across isolates
class _PathCalculationParams {
  final List<Map<String, dynamic>> serializedAisles;
  final Map<String, dynamic> serializedStart;
  final Map<String, dynamic> serializedEnd;

  const _PathCalculationParams({
    required this.serializedAisles,
    required this.serializedStart,
    required this.serializedEnd,
  });
}

/// Message sent from the main isolate to the worker isolate
class _IsolateMessage {
  final _PathCalculationParams params;
  final SendPort sendPort;

  const _IsolateMessage({
    required this.params,
    required this.sendPort,
  });
}

/// Serialization helpers
Map<String, dynamic> _serializeOffset(Offset offset) {
  return {'dx': offset.dx, 'dy': offset.dy};
}

Offset _deserializeOffset(Map<String, dynamic> map) {
  return Offset(map['dx'] as double, map['dy'] as double);
}

Map<String, dynamic> _serializePathfindingAisle(PathfindingAisle aisle) {
  return {
    'topLeft': _serializeOffset(aisle.topLeft),
    'height': aisle.height,
    'width': aisle.width,
    'isTarget': aisle.isTarget,
    'id': aisle.id,
  };
}

PathfindingAisle _deserializePathfindingAisle(Map<String, dynamic> map) {
  return PathfindingAisle(
    topLeft: _deserializeOffset(map['topLeft'] as Map<String, dynamic>),
    height: map['height'] as int,
    width: map['width'] as int,
    isTarget: map['isTarget'] as bool,
    id: map['id'] as String,
  );
}

Map<String, dynamic> _serializeWaypoint(Waypoint waypoint) {
  return {
    'position': _serializeOffset(waypoint.position),
    'targetAisleIndex': waypoint.targetAisleIndex,
  };
}

Waypoint _deserializeWaypoint(Map<String, dynamic> map) {
  return Waypoint(
    position: _deserializeOffset(map['position'] as Map<String, dynamic>),
    targetAisleIndex: map['targetAisleIndex'] as int?,
  );
}

/// Isolate entry point - this runs in a separate isolate
void _calculatePathIsolate(_IsolateMessage message) {
  // Deserialize parameters
  final aisles = message.params.serializedAisles
      .map((a) => _deserializePathfindingAisle(a))
      .toList();
  final start = _deserializeOffset(message.params.serializedStart);
  final end = _deserializeOffset(message.params.serializedEnd);

  // Perform the expensive calculation
  final result = calculatePath(
    aisles: aisles,
    start: start,
    end: end,
  );

  // Serialize the result
  final serializedResult = result.map((w) => _serializeWaypoint(w)).toList();

  // Send back to main isolate
  message.sendPort.send(serializedResult);
}

/// Calculate path in a separate isolate to avoid blocking the main thread
///
/// This is a wrapper around [calculatePath] that runs the expensive pathfinding
/// calculation in a separate isolate, preventing UI blocking.
Future<List<Waypoint>> calculatePathInIsolate({
  required List<PathfindingAisle> aisles,
  required Offset start,
  required Offset end,
}) async {
  // Create a ReceivePort to get messages from the isolate
  final receivePort = ReceivePort();

  // Serialize parameters
  final params = _PathCalculationParams(
    serializedAisles: aisles.map((a) => _serializePathfindingAisle(a)).toList(),
    serializedStart: _serializeOffset(start),
    serializedEnd: _serializeOffset(end),
  );

  // Spawn the isolate
  await Isolate.spawn(
    _calculatePathIsolate,
    _IsolateMessage(
      params: params,
      sendPort: receivePort.sendPort,
    ),
  );

  // Wait for the result
  final serializedResult = await receivePort.first as List<dynamic>;

  // Deserialize and return
  return serializedResult
      .map((w) => _deserializeWaypoint(w as Map<String, dynamic>))
      .toList();
}
