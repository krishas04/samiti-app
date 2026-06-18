import 'package:flutter/material.dart';
import 'package:samiti_app/features/accident/model/accident_model.dart';
import 'package:samiti_app/features/accident/repository/accident_repository.dart';

import '../../../core/network/connectivity_service.dart';
import '../../../core/sync/sync_engine.dart';

class AccidentViewModel extends ChangeNotifier {
  final AccidentRepository repository;
  final SyncEngine syncEngine;
  final ConnectivityService connectivity;

  List<AccidentModel> accidents = [];
  AccidentModel? selectedAccident;
  bool isLoading = false;
  bool isFromCache = false;
  String? error;

  AccidentViewModel({
    required this.repository,
    required this.syncEngine,
    required this.connectivity,
  }){
    // When connectivity changes, auto sync
    connectivity.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged(){
    if (connectivity.isOnline) {
      fetchAccidents();
    }
  }

  Future<void> fetchAccidents() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // step 1: show local data
      accidents = await repository.getAccidents();
      isFromCache= true;
      isLoading = false;
      notifyListeners();

      // step 2 : sync if online
      if(connectivity.isOnline){
        await syncEngine.sync();
        accidents = await repository.getAccidents();
        isFromCache = false;
        notifyListeners();
      }
    } catch (e) {
      print('fetchAccidents error: $e');
      if (accidents.isEmpty) {
        error = connectivity.isOnline
            ? 'Failed to load. Please retry.'
            : 'No internet. Showing cached data.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAccident(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      selectedAccident = await repository.getAccident(id);
    } catch (e) {
      error = 'Failed to load accident details.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAccident({
    required Map<String, String> fields,
    List<String> imagePaths=const [],
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final newAccident = await repository.createAccident(
        fields: fields,
        imagePaths: imagePaths,
      );
      accidents = [newAccident, ...accidents];
      return true;
    } catch (e) {
      print('createAccident error: $e');
      error = 'Failed to create accident. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAccident({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final updated = await repository.updateAccident(id: id, body: body);
      accidents = accidents.map((v) => v.id == id ? updated : v).toList();
      return true;
    } catch (e) {
      error = 'Failed to update accident.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccident(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await repository.deleteAccident(id: id, );
      accidents = accidents.where((v) => v.id != id).toList();
      return true;
    } catch (e) {
      error = 'Failed to delete accident.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  @override
  void dispose() {
    connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}