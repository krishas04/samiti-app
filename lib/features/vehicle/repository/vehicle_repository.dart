//  decides — local or API
import 'dart:convert';
import 'package:samiti_app/core/utils/image_cache_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:samiti_app/core/database/outbox_local_db.dart';
import 'package:samiti_app/core/api/api_constants.dart';
import 'package:samiti_app/core/network/connectivity_service.dart';
import '../api/vehicle_api.dart';
import '../localdb/vehicle_local_db.dart';
import '../model/vehicle_model.dart';

class VehicleRepository {
  final VehicleApi api;
  final VehicleLocalDb localDb;
  final OutboxLocalDb outboxDb;
  final ConnectivityService connectivity;

  VehicleRepository({
    required this.api,
    required this.localDb,
    required this.outboxDb,
    required this.connectivity,
  });

  // READ — always local DB first
  Future<List<VehicleModel>> getVehicles() async {
    return localDb.getVehicles();
  }

  Future<VehicleModel?> getVehicle(int id) async {
    return localDb.getVehicle(id);
  }

  // CREATE — online: API then save local
  //          offline: save local + queue outbox
  Future<VehicleModel> createVehicle({
    required Map<String, String> fields,
    String? imagePath,
  }) async {
    final cacheHelper= ImageCacheHelper();

    if (connectivity.isOnline) {
      final vehicle = await api.createVehicle(
        fields: fields,
        imagePath: imagePath,
      );
      // vehicle includes instance of VehicleModel returned by server which includes remote url in vehicleImage field

      // After upload, download and cache the image
      if (vehicle.vehicleImage != null) {
        final localPath = await cacheHelper.downloadAndSaveImage(
            vehicle.vehicleImage!,
            vehicle.id
        );
        final vehicleWithLocalPath = VehicleModel(
          id: vehicle.id,
          displayName: vehicle.displayName,
          vehicleNo: vehicle.vehicleNo,
          isActive: vehicle.isActive,
          fuelType: vehicle.fuelType,
          modelNo: vehicle.modelNo,
          vehicleImage: vehicle.vehicleImage,
          localImagePath: localPath,
          partner: vehicle.partner,
          vehicleBrand: vehicle.vehicleBrand,
          vehicleType: vehicle.vehicleType,
        );
        await localDb.upsertVehicle(vehicleWithLocalPath);
        return vehicleWithLocalPath;
      }
      // No image from server
      await localDb.upsertVehicle(vehicle);
      return vehicle;
    } else {
      // offline
      //generate negative temp ID
      final tempId = -DateTime.now().millisecondsSinceEpoch;

      // save image to permanent storage
      final savedImagePath= await cacheHelper.saveImage(imagePath, tempId);

      // create optimistic record in local db
      await localDb.insertOptimistic(fields, tempId, savedImagePath);

      final payload = Map<String, dynamic>.from(fields);
      payload['_local_temp_id'] = tempId;

      // add to outbox queue for later sync
      await outboxDb.enqueue(
        id: const Uuid().v4(),
        operation: 'create',
        resource: 'vehicle',
        endpoint: ApiConstants.vehicles,
        payload: jsonEncode(payload),
        method: 'POST',
        pendingImagePath: savedImagePath,
      );

      // Get cached objects for the returned VehicleModel
      final partner = await localDb.getPartnerById(int.tryParse(fields['partner'] ?? ''));
      final brand = await localDb.getBrandById(int.tryParse(fields['vehicle_brand'] ?? ''));
      final type = await localDb.getTypeById(int.tryParse(fields['vehicle_type'] ?? ''));

      final vehicle = VehicleModel(
        id: tempId,
        displayName: fields['display_name'] ?? '',
        vehicleNo: fields['vehicle_no'] ?? '',
        isActive: true,
        fuelType: fields['fuel_type'],
        createdAt: DateTime.now().millisecondsSinceEpoch,
        modelNo: fields['model_no'],
        partnerId: fields['partner'] != null
            ? int.parse(fields['partner']!)
            : null,
        vehicleBrandId: fields['vehicle_brand'] != null ? int.parse(
            fields['vehicle_brand']!) : null,
        vehicleTypeId: fields['vehicle_type'] != null ? int.parse(
            fields['vehicle_type']!) : null,
        partner: partner,
        vehicleBrand: brand,
        vehicleType: type,
        vehicleImage: imagePath,
        localImagePath: savedImagePath,
      );
      return vehicle;
    }
  }

  // UPDATE
  Future<VehicleModel> updateVehicle({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    if (connectivity.isOnline) {
      final vehicle = await api.updateVehicle(id: id, body: body);
      await localDb.upsertVehicle(vehicle);
      return vehicle;
    } else {
      await localDb.updateSyncStatus(id, 'pending_update');
      await outboxDb.enqueue(
        id: const Uuid().v4(),
        operation: 'update',
        resource: 'vehicle',
        endpoint: '${ApiConstants.vehicles}$id/',
        payload: jsonEncode(body),
        method: 'PATCH',
      );
      return (await localDb.getVehicle(id))!;
    }
  }

  // DELETE
  Future<void> deleteVehicle({required int id}) async {
    if (connectivity.isOnline) {
      await api.deleteVehicle(id);
      await localDb.deleteVehicle(id);
    } else {
      await localDb.updateSyncStatus(id, 'pending_delete');
      await outboxDb.enqueue(
        id: const Uuid().v4(),
        operation: 'delete',
        resource: 'vehicle',
        endpoint: '${ApiConstants.vehicles}$id/',
        payload: '{}',
        method: 'DELETE',
      );
    }
  }

  // Dropdown methods
  Future<List<VehiclePartnerEmbed>> getPartners() async {
    // get from local db first
    final cached = await localDb.getCachedPartners();

    // if online then refresh from api
    if (connectivity.isOnline) {
      try {
        final fresh = await api.fetchPartners();
        await localDb.cachePartners(fresh);
        return fresh;
      } catch (e) {
        if (cached.isNotEmpty) return cached;
      }
    }

    return cached;
  }

  Future<List<VehicleBrandEmbed>> getVehicleBrands() async {
    final cached = await localDb.getCachedBrands();

    if (connectivity.isOnline) {
      try {
        final fresh = await api.fetchVehicleBrands();
        await localDb.cacheBrands(fresh);
        return fresh;
      } catch (e) {
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    }

    return cached;
  }

  Future<List<VehicleTypeEmbed>> getVehicleTypes() async {
    final cached = await localDb.getCachedTypes();

    if (connectivity.isOnline) {
      try {
        final fresh = await api.fetchVehicleTypes();
        await localDb.cacheTypes(fresh);
        return fresh;
      } catch (e) {
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    }

    return cached;
  }

  // Future _saveImageToPermanentStorage(String imagePath, int tempId) async {
  //   try{
  //     final dbPath= await getDatabasesPath();
  //     final fileName= 'vehicle_${tempId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //     final newPath= join(dbPath,fileName);
  //
  //     final imageFile= File(imagePath);
  //     if (!await imageFile.exists()) return null;
  //     imageFile.copy(newPath);  //copy image file to new permanent location
  //     return newPath;
  //   }catch(e){
  //     print('Failed to save image.');
  //     return null;
  //   }
  // }
}