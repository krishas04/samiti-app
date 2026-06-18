import 'dart:convert';
import 'dart:io';
import 'package:samiti_app/core/database/outbox_local_db.dart';
import 'package:samiti_app/features/accident/api/accident_api.dart';
import 'package:samiti_app/features/accident/localdb/accident_local_db.dart';
import 'package:samiti_app/features/vehicle/api/vehicle_api.dart';

import '../../features/vehicle/localdb/vehicle_local_db.dart';
import '../utils/image_cache_helper.dart';

class SyncEngine {
  final VehicleApi vehicleApi;
  final VehicleLocalDb vehicleLocalDb;
  final AccidentApi? accidentApi;
  final AccidentLocalDb? accidentLocalDb;
  final OutboxLocalDb outboxDb;

  bool _running = false;

  SyncEngine({
    required this.vehicleApi,
    required this.vehicleLocalDb,
    this.accidentApi,
    this.accidentLocalDb,
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
    else if (resource == 'accident') {
      await _executeAccidentOp(operation, payload, endpoint, pendingImagePath);
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
          // delete old image file
          if (pendingImagePath != null) {
            await File(pendingImagePath).delete();
          }
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
    await _pullAccidents();
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

  Future<void> _executeAccidentOp(
      String operation,
      Map<String, dynamic> payload,
      String endpoint,
      String? pendingImagePath,
      ) async {
    if (accidentApi == null || accidentLocalDb == null) return;

    switch (operation) {
      case 'create':
        final tempId = payload['_local_temp_id'] as int?;
        final imagePaths = (payload['_image_paths'] as List<dynamic>?)?.cast<String>() ?? [];
        if (pendingImagePath != null && !imagePaths.contains(pendingImagePath)) {
          imagePaths.insert(0, pendingImagePath);
        }

        // Remove internal fields
        final fields = Map<String, String>.from(payload
          ..remove('_local_temp_id')
          ..remove('_image_paths')
          ..remove('_image_count'))
            .map((k, v) => MapEntry(k, v.toString()));

        final created = await accidentApi!.createAccident(
          fields: fields,
          imagePaths: imagePaths,
        );

        // Cache server images permanently
        final cacheHelper = ImageCacheHelper();
        final localPaths = <String>[];
        for (final img in created.images) {
          if (img.image.startsWith('http')) {
            final localPath = await cacheHelper.downloadAndSaveImage(
              img.image,
              created.id,
            );
            if (localPath != null) localPaths.add(localPath);
          }
        }

        // Delete temp record, save real record
        if (tempId != null) {
          await accidentLocalDb!.deleteAccident(tempId);
        }

        final createdWithCache = created.copyWith(
          localImagePaths: localPaths,
        );
        await accidentLocalDb!.upsertAccident(createdWithCache);
        break;

      case 'update':
        final parts = endpoint.split('/');
        final id = int.parse(parts[parts.length - 2]);
        final updated = await accidentApi!.updateAccident(id: id, body: payload);
        await accidentLocalDb!.upsertAccident(updated);
        break;

      case 'delete':
        final parts = endpoint.split('/');
        final id = int.parse(parts[parts.length - 2]);
        await accidentApi!.deleteAccident(id:id);
        await accidentLocalDb!.deleteAccident(id);
        break;
    }
  }

  Future<void> _pullAccidents() async {
    if (accidentApi == null || accidentLocalDb == null) return;
    try {
      final accidents = await accidentApi!.getAccidents();
      await accidentLocalDb!.upsertAccidents(accidents);
    } catch (e) {
      print('Pull accidents error: $e');
    }
  }
}