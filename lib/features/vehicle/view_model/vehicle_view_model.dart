import 'package:flutter/material.dart';

import '../model/vehicle_model.dart';
import '../repository/vehicle_repository.dart';

class VehicleViewModel extends ChangeNotifier {
  final VehicleRepository repository;

  List<VehicleModel> vehicles = [];
  VehicleModel? selectedVehicle;
  bool isLoading = false;
  String? error;

  VehicleViewModel({required this.repository, required String token});

  Future<void> fetchVehicles() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      vehicles = await repository.getVehicles();
    } catch (e) {
      error = 'Failed to load vehicles. Please try again.';
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
      selectedVehicle = await repository.getVehicle(id: id);
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
      return true;
    } catch (e) {
      print(e);
      error = 'Failed to create vehicle. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
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
}