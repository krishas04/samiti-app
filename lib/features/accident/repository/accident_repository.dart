import 'dart:convert';

import 'package:samiti_app/core/database/outbox_local_db.dart';
import 'package:samiti_app/core/network/connectivity_service.dart';
import 'package:samiti_app/features/accident/localdb/accident_local_db.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_constants.dart';
import '../../../core/utils/image_cache_helper.dart';
import '../api/accident_api.dart';
import '../model/accident_model.dart';

class AccidentRepository{
  final AccidentApi api;
  final AccidentLocalDb localDb;
  final OutboxLocalDb outboxDb;
  final ConnectivityService connectivity;

  AccidentRepository({
    required this.api,
    required this.localDb,
    required this.outboxDb,
    required this.connectivity
  });

  // always read from localDb first
  Future<List<AccidentModel>> getAccidents() async {
    return localDb.getAccidents();
  }

  Future<AccidentModel?> getAccident(int id) async {
    return localDb.getAccident(id);
  }

  // create- branch online and offline
  Future<AccidentModel> createAccident({
    required Map<String, String> fields,
    List<String> imagePaths = const [] // default value
  }) async {
    final cacheHelper= ImageCacheHelper();
    if(connectivity.isOnline){
      // when online- send to server
      final accident = await api.createAccident(
          fields: fields,
          imagePaths: imagePaths
      );

      final localPaths = await _cacheServerImages(accident,cacheHelper);

      final accidentWithCache= accident.copyWith(
        localImagePaths: localPaths,
      );

      await localDb.upsertAccident(accidentWithCache);

      return accidentWithCache;
    }else{
      // offline- save locally , then add to queue for sync
      final tempId= -DateTime.now().millisecondsSinceEpoch;

      // save all images to permanent storage
      final savedImagePaths = <String>[];
      for (int i = 0; i < imagePaths.length; i++) {
        final saved = await cacheHelper.saveImage(imagePaths[i], tempId + i);
        if (saved != null) savedImagePaths.add(saved);
      }

      // Create optimistic record
      await localDb.insertOptimistic(fields, tempId, savedImagePaths);
      
      // Queue for sync
      final payload = Map<String, dynamic>.from(fields);
      payload['_local_temp_id'] = tempId;
      payload['_image_count'] = savedImagePaths.length;
      payload['_image_paths'] = savedImagePaths;

      await outboxDb.enqueue(
        id: const Uuid().v4(),
        operation: 'create',
        resource: 'accident',
        endpoint: ApiConstants.accidents,
        payload: jsonEncode(payload),
        method: 'POST',
        pendingImagePath: savedImagePaths.isNotEmpty 
            ? savedImagePaths.first 
            : null,
      );

      // Return temporary model for optimistic UI
      return _buildTempAccident(fields, tempId, savedImagePaths);
    }
  }
// UPDATE
  Future<AccidentModel> updateAccident({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    if (connectivity.isOnline) {
      final accident = await api.updateAccident(id: id, body: body);
      await localDb.upsertAccident(accident);
      return accident;
    } else {
      await localDb.updateSyncStatus(id, 'pending_update');
      await outboxDb.enqueue(
        id: const Uuid().v4(),
        operation: 'update',
        resource: 'accident',
        endpoint: '${ApiConstants.accidents}$id/',
        payload: jsonEncode(body),
        method: 'PATCH',
      );
      return (await localDb.getAccident(id))!;
    }
  }

  // DELETE
  Future<void> deleteAccident({required int id}) async {
    if (connectivity.isOnline) {
      await api.deleteAccident(id:id);
      await localDb.deleteAccident(id);
    } else {
      await localDb.updateSyncStatus(id, 'pending_delete');
      await outboxDb.enqueue(
        id: const Uuid().v4(),
        operation: 'delete',
        resource: 'accident',
        endpoint: '${ApiConstants.accidents}$id/',
        payload: '{}',
        method: 'DELETE',
      );
    }
  }

  // Helper: Download server images to permanent cache
  Future<List<String>> _cacheServerImages(
      AccidentModel accident,
      ImageCacheHelper cacheHelper,
      ) async {
    final localPaths = <String>[];
    for (final img in accident.images) {
      if (img.image.startsWith('http')) {
        final localPath = await cacheHelper.downloadAndSaveImage(
          img.image,
          accident.id,
        );
        if (localPath != null) localPaths.add(localPath);
      }
    }
    return localPaths;
  }

  // Helper: Build temporary accident model for optimistic UI
  AccidentModel _buildTempAccident(
      Map<String, String> fields,
      int tempId,
      List<String> imagePaths,
      ) {
    return AccidentModel(
      id: tempId,
      displayName: fields['name'] ?? '',
      name: fields['name'] ?? '',
      isActive: true,
      accidentDate: fields['accident_date'],
      driverName: fields['driver_name'],
      accidentPlace: fields['accident_place'],
      accidentCause: fields['accident_cause'],
      remarks: fields['remarks'],
      vehicle: null, // Will be resolved from cache if needed
      images: imagePaths.asMap().entries.map((e) => AccidentImageModel(
        id: e.key,
        image: e.value,
        isLocal: true,
      )).toList(),
      syncStatus: 'pending_create',
      localImagePaths: imagePaths,
    );
  }
}
