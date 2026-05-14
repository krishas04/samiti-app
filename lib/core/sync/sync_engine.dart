import 'dart:convert';
import 'package:samiti_app/core/database/outbox_local_db.dart';
import 'package:samiti_app/features/vehicle/api/vehicle_api.dart';
import 'package:samiti_app/features/vehicle/model/vehicle_model.dart';

import '../../features/vehicle/localdb/vehicle_local_db.dart';

class SyncEngine {
  final VehicleApi vehicleApi;
  final VehicleLocalDb vehicleLocalDb;
  final OutboxLocalDb outboxDb;

  bool _running = false;

  SyncEngine({
    required this.vehicleApi,
    required this.vehicleLocalDb,
    required this.outboxDb,
  });

  Future<void> sync() async {
    if (_running) return;
    _running = true;

    try {
      await _drainOutbox();
      await _pullAll();
    } finally {
      _running = false;
    }
  }

  // PUSH: send pending outbox ops to server
  Future<void> _drainOutbox() async {
    final ops = await outboxDb.getPending();

    for (final op in ops) {
      try {
        await _executeOp(op);
        await outboxDb.remove(op['id'] as String);
      } catch (e) {
        await outboxDb.markFailed(
          op['id'] as String,
          e.toString(),
          op['retry_count'] as int,
        );
        print('Outbox failed: ${op['id']} — $e');
      }
    }
  }

  Future<void> _executeOp(Map<String, dynamic> op) async {
    final resource = op['resource'] as String;
    final operation = op['operation'] as String;
    final payload = jsonDecode(op['payload'] as String) as Map<String, dynamic>;
    final endpoint = op['endpoint'] as String;
    final pendingImagePath= op['pending_image_path'] as String;

    if (resource == 'vehicle') {
      await _executeVehicleOp(operation, payload, endpoint, pendingImagePath);
    }
    // Add accident, etc. here as you build them
  }

  Future<void> _executeVehicleOp(
      String operation,
      Map<String, dynamic> payload,
      String endpoint,
      String pendingImagePath,
      ) async {
    switch (operation) {
      case 'create':
        final tempId = payload['_local_temp_id'] as int?;
        // Remove internal fields before sending
        final fields = Map<String, String>.from(
          payload..remove('_local_temp_id'),
        ).map((k, v) => MapEntry(k, v.toString()));

        final created = await vehicleApi.createVehicle(fields: fields,imagePath: pendingImagePath);

        // Delete temporary local record
        if (tempId != null) {
          await vehicleLocalDb.deleteVehicle(tempId);
        }
        // Save real server record locally
        await vehicleLocalDb.upsertVehicle(created);
        break;

      case 'update':
      // Extract id from endpoint /v1/vehicles/3/
        final parts = endpoint.split('/');
        final id = int.parse(parts[parts.length - 2]);
        final updated = await vehicleApi.updateVehicle(id: id, body: payload);
        await vehicleLocalDb.upsertVehicle(updated);
        break;

      case 'delete':
        final parts = endpoint.split('/');
        final id = int.parse(parts[parts.length - 2]);
        await vehicleApi.deleteVehicle(id);
        await vehicleLocalDb.deleteVehicle(id);
        break;
    }
  }

  // PULL: fetch fresh data from server → save to local DB
  Future<void> _pullAll() async {
    await _pullVehicles();
    // Add _pullAccidents() here later
  }

  Future<void> _pullVehicles() async {
    try {
      // Reuse VehicleApi — no duplicate HTTP code
      final vehicles = await vehicleApi.fetchVehicles();
      await vehicleLocalDb.upsertVehicles(vehicles);
    } catch (e) {
      print('Pull vehicles error: $e');
    }
  }
}