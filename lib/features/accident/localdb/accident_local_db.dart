import 'dart:convert';

import 'package:samiti_app/core/database/db_helper.dart';
import 'package:samiti_app/features/accident/model/accident_model.dart';
import 'package:sqflite/sqflite.dart';

class AccidentLocalDb{
  Future<Database> get _db => DbHelper.instance.database;

  // read all accidents
  Future<List<AccidentModel>> getAccidents() async {
    final db= await _db;
    final rows= await db.query(
      'accidents',
      where: 'sync_status != ?',
      whereArgs: ['pending_delete'],
      orderBy: 'created_at DESC',
    );
    return rows.map(_rowsToModel).toList();
  }

  // read single
  Future<AccidentModel?> getAccident(int id) async{
    final db= await _db;
    final rows= await db.query(
      'accidents',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if(rows.isEmpty) return null;
    return _rowsToModel(rows.first);
  }

  // upsert = update or insert
  Future<void> upsertAccident(AccidentModel accident,{String syncStatus = 'synced'}) async{
    final db = await _db;
    await db.insert(
        'accidents',
        _modelToRow(accident, syncStatus: syncStatus),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // upsert batch
  Future<void> upsertAccidents(List<AccidentModel> accidents) async{
    final db = await _db;
    final batch = db.batch();
    for (final a in accidents) {
      batch.insert(
        'accidents',
        _modelToRow(a, syncStatus: 'synced'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // optimistic insert- for offline creation
  Future<void> insertOptimistic(
      Map<String, String> fields,
      int tempId,
      List<String>? imagePaths,
      ) async{
    final db = await _db;

    // Fetch cached vehicle for embedding
    final vehicle = await _getCachedVehicle(int.tryParse(fields['vehicle'] ?? ''));

    await db.insert(
        'accidents',
        {
          'id': tempId,
          'name': fields['name'] ?? '',
          'display_name': fields['name'] ?? '',
          'is_active': 1,
          'accident_date': fields['accident_date'],
          'driver_name': fields['driver_name'],
          'accident_place': fields['accident_place'],
          'accident_cause': fields['accident_cause'],
          'remarks': fields['remarks'],
          'vehicle_json': vehicle != null
              ? jsonEncode(vehicle.toJson())
              : null,
          'images_json': imagePaths != null
              ? jsonEncode(imagePaths)
              : null,
          'sync_status': 'pending_create',
          'synced_at': null,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        }
    );
  }

  // DELETE
  Future<void> deleteAccident(int id) async {
    final db = await _db;
    await db.delete(
      'accidents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // update sync_status
  Future<void> updateSyncStatus(int id, String status) async {
    final db = await _db;
    await db.update(
      'accidents',
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // row -> model
  AccidentModel _rowsToModel(Map<String, Object?> row) {
    final imagesJson= row['images_json'] as String?;  // get JSON String or null
    final imagePaths = imagesJson != null
        ? (jsonDecode(imagesJson) as List<dynamic>).cast<String>()  // decode as List<String>
        :null;
    final createdAt = _calculateCreatedAt(row);
    return AccidentModel(
        id: row['id'] as int,
        displayName: row['display_name'] as String,
        name: row['name'] as String,
        isActive: (row['is_active'] as int) == 1,
        accidentDate: row['accident_date'] as String?,
        driverName: row['driver_name'] as String?,
        accidentPlace: row['accident_place'] as String?,
        accidentCause: row['accident_cause'] as String?,
        remarks: row['remarks'] as String?,
        vehicle: row['vehicle_json'] != null
            ? AccidentVehicleEmbed.fromJson(jsonDecode(row['vehicle_json'] as String))
            : null,
        // convert List<String> into a List<AccidentImageModel>
        images: imagePaths != null
            ? imagePaths.asMap().entries.map((e) =>
            AccidentImageModel(id: e.key, image: e.value)).toList()
            : [],
        createdAt: createdAt
    );
  }

  // model -> row
  Map<String, Object?> _modelToRow(AccidentModel a, {String syncStatus= 'synced'}){
    // converting a list of objects (likely from a.images) into a list of strings (image paths/URLs).
    final imagePaths= a.images.map((img)=> img.image).toList();
    return {
      'id': a.id,
      'name': a.name,
      'display_name': a.displayName,
      'is_active': a.isActive ? 1 : 0,
      'accident_date': a.accidentDate,
      'driver_name': a.driverName,
      'accident_place': a.accidentPlace,
      'accident_cause': a.accidentCause,
      'remarks': a.remarks,
      'sync_status': syncStatus,
      'synced_at': DateTime.now().toIso8601String(),
      'vehicle_json': a.vehicle != null 
          ? jsonEncode(a.vehicle!.toJson())
          :null,
      'images_json': imagePaths.isNotEmpty
          ? jsonEncode(imagePaths)
          :null,
      'created_at': a.createdAt,

    };
  }

  // function to calculate value for createAt field
  int _calculateCreatedAt(Map<String, Object?> row) {
    final rawCreatedAt = row['created_at'];
    final id = row['id'] as int;

    // Check if created_at exists and is an integer
    if (rawCreatedAt != null && rawCreatedAt is int) {
      return rawCreatedAt;
    }

    // For negative IDs (pending offline records)
    if (id < 0) {
      return DateTime.now().millisecondsSinceEpoch;
    }

    // For all other cases (null, zero, invalid)
    // Calculate based on ID
    final baseTimestamp = DateTime(2026, 1, 1).millisecondsSinceEpoch;
    final multiplier = 86400000; // 1 day in milliseconds
    return baseTimestamp + ((id - 1) * multiplier);
  }

  // helper: get cached vehicle from localDb( reuse vehicles table)
  Future<AccidentVehicleEmbed?> _getCachedVehicle(int? id) async {
    if(id == null) return null;
    final db= await _db;
    final rows= await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row= rows.first;
    return AccidentVehicleEmbed(
        id: row['id'] as int,
        vehicleNo: row['vehicle_no'] as String,
        isActive: (row['is_active'] as int) == 1,
    );
  }

}