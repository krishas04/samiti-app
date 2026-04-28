import 'package:flutter/material.dart';
import 'package:samiti_app/features/accident/model/accident_model.dart';
import 'package:samiti_app/features/accident/repository/accident_repository.dart';

class AccidentViewModel extends ChangeNotifier {
  final AccidentRepository repository;

  List<AccidentModel> accidents = [];
  AccidentModel? selectedAccident;
  bool isLoading = false;
  String? error;

  AccidentViewModel({required this.repository, required String token});

  Future<void> fetchAccidents() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      accidents = await repository.getAccidents();
    } catch (e) {
      error = 'Failed to load accidents. Please try again.';
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
      selectedAccident = await repository.getAccident(id: id);
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
      print(e);
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
}