import 'package:flutter/material.dart';

import '../../../core/network/connectivity_service.dart';
import '../../../core/sync/sync_engine.dart';
import '../model/vehicle_model.dart';
import '../repository/vehicle_repository.dart';

class VehicleViewModel extends ChangeNotifier {
  final VehicleRepository repository;
  final SyncEngine syncEngine;
  final ConnectivityService connectivity;

  List<VehicleModel> vehicles = [];
  VehicleModel? selectedVehicle;
  bool isLoading = false;
  bool isFromCache = false;
  String? error;

  VehicleViewModel({
    required this.repository,
    required this.syncEngine,
    required this.connectivity,
  }){
    // When connectivity changes, auto sync
    connectivity.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (connectivity.isOnline) {
      // Back online — sync immediately
      fetchVehicles();
    }
  }

  Future<void> fetchVehicles() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // STEP 1: Show local data immediately
      vehicles = await repository.getVehicles();
      isFromCache = true;
      isLoading = false;
      notifyListeners();

      // STEP 2: If online, sync from server in background
      if (connectivity.isOnline) {
        await syncEngine.sync(); // drain outbox + pull fresh

        // STEP 3: Reload from local DB (now has fresh server data)
        vehicles = await repository.getVehicles();
        isFromCache = false;
        notifyListeners();
      }

    } catch (e) {
      print('fetchVehicles error: $e');
      if (vehicles.isEmpty) {
        error = connectivity.isOnline
            ? 'Failed to load. Please retry.'
            : 'No internet. Showing cached data.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVehicle(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      selectedVehicle = await repository.getVehicle(id);
    } catch (e) {
      error = 'Failed to load vehicle details.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createVehicle({
    required Map<String, String> fields,
    String? imagePath,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final newVehicle = await repository.createVehicle(
        fields: fields,
        imagePath: imagePath,
      );
      vehicles = [newVehicle, ...vehicles];
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('createVehicle error: $e');
      error = 'Failed to create vehicle. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicle({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final updated = await repository.updateVehicle(id: id, body: body);
      vehicles = vehicles.map((v) => v.id == id ? updated : v).toList();
      return true;
    } catch (e) {
      error = 'Failed to update vehicle.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVehicle(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await repository.deleteVehicle(id: id, );
      vehicles = vehicles.where((v) => v.id != id).toList();
      return true;
    } catch (e) {
      error = 'Failed to delete vehicle.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<VehiclePartnerEmbed>> getPartners() async {
    try {
      return await repository.getPartners();
    } catch (e) {
      print('getPartners error: $e');
      return []; // Return empty list on error
    }
  }

  Future<List<VehicleBrandEmbed>> getVehicleBrands() async {
    try {
      return await repository.getVehicleBrands();
    } catch (e) {
      print('getVehicleBrands error: $e');
      return [];
    }
  }

  Future<List<VehicleTypeEmbed>> getVehicleTypes() async {
    try {
      return await repository.getVehicleTypes();
    } catch (e) {
      print('getVehicleTypes error: $e');
      return [];
    }
  }

  @override
  void dispose() {
    connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}