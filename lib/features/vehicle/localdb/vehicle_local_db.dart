import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/database/db_helper.dart';
import '../model/vehicle_model.dart';

class VehicleLocalDb{
  Future<Database> get _db=> DbHelper.instance.database;

  // read all vehicles
  Future<List<VehicleModel>> getVehicles() async{
    final db= await _db;
    final rows= await db.query(
      'vehicles',
      where: 'sync_status != ?',
      whereArgs: ['pending_delete'],
      orderBy: 'id DESC'  //higher id= newer record
    );
    return rows.map(_rowToModel).toList();
  }

  //read single vehicle
  Future<VehicleModel?> getVehicle(int id) async {
    final db= await _db;
    final rows= await db.query(
      'vehicles',
      where: 'id=?',
      whereArgs: [id],
      limit: 1
    );
    if (rows.isEmpty) return null;
    return _rowToModel(rows.first);
  }

  // Upsert= insert or replace if id exists
  // single vehicle
  Future<void> upsertVehicle(VehicleModel vehicle, {String syncStatus='synced'}) async{
    final db = await _db;
    await db.insert(
        'vehicles',
        _modelToRow(vehicle,syncStatus: syncStatus),
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // upsert multiple
  Future<void> upsertVehicles(List<VehicleModel> vehicles) async{
    final db= await _db;
    final batch= db.batch();
    for (final v in vehicles){
      batch.insert(
          'vehicles',
          _modelToRow(v,syncStatus: 'synced'),
        conflictAlgorithm: ConflictAlgorithm.replace
      );
      await batch.commit(noResult: true);
    }
  }

  // insert temporary optimistic record with negative id
  // optimistic insert ie. instant UI updates even without internet
  Future<void> insertOptimistic(Map<String, String> fields, int tempId, String? imagePath ) async {
    final db= await _db;

    // get full cached objects
    final partner = await getPartnerById(int.tryParse(fields['partner'] ?? ''));
    final brand = await getBrandById(int.tryParse(fields['vehicle_brand'] ?? ''));
    final type = await getTypeById(int.tryParse(fields['vehicle_type'] ?? ''));

    await db.insert(
        'vehicles',
        {
          'id': tempId,
          'vehicle_no': fields['vehicle_no'] ?? '',
          'display_name': fields['vehicle_no'] ?? '',
          'is_active': 1,
          'fuel_type': fields['fuel_type'],
          'model_no': fields['model_no'],
          'partner_id': int.tryParse(fields['partner'] ?? ''),
          'vehicle_brand_id': int.tryParse(fields['vehicle_brand'] ?? ''),
          'vehicle_type_id': int.tryParse(fields['vehicle_type'] ?? ''),
          'partner_json': partner != null ? jsonEncode(partner.toJson()) : null,
          'vehicle_brand_json': brand != null ? jsonEncode(brand.toJson()) : null,
          'vehicle_type_json': type != null ? jsonEncode(type.toJson()) : null,
          'sync_status': 'pending_create',
          'synced_at': null,

          'vehicle_image': imagePath,
        }
    );
  }

  //delete local record
  Future<void> deleteVehicle(int id) async{
    final db= await _db;
    await db.delete(
        'vehicles',
        where: 'id = ?',
      whereArgs: [id]
    );
  }

  //update sync status
  Future<void> updateSyncStatus (int id, String status)async{
    final db=await _db;
    await db.update(
        'vehicles',
        {'sync_status':status},
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  // convert db row ie. json to VehicleModel object
  VehicleModel _rowToModel(Map<String, Object?> row) {
    return VehicleModel(
        id: row['id'] as int,
        vehicleNo: row['vehicle_no'] as String,
        displayName: row['display_name'] as String,
        isActive: (row['is_active'] as int) == 1, //returns bool
        fuelType: row['fuel_type'] as String?,
        modelNo: row['model_no'] as String?,
        vehicleImage: row['vehicle_image'] as String?,
        partnerId: row['partner_id'] as int?,
        vehicleBrandId: row['vehicle_brand_id'] as int?,
        vehicleTypeId: row['vehicle_type_id'] as int?,
        partner: row['partner_json'] != null
            ? VehiclePartnerEmbed.fromJson(
            jsonDecode(row['partner_json'] as String))
            : null,
        vehicleBrand: row['vehicle_brand_json'] != null
            ? VehicleBrandEmbed.fromJson(
            jsonDecode(row['vehicle_brand_json'] as String))
            : null,
        vehicleType: row['vehicle_type_json'] != null
            ? VehicleTypeEmbed.fromJson(
            jsonDecode(row['vehicle_type_json'] as String))
            : null,
      );
  }

  // convert VehicleModel to db row ie.json
  Map<String, Object?> _modelToRow(VehicleModel v, {String syncStatus= 'synced'}) {
    return {
      'id':v.id,
      'vehicle_no': v.vehicleNo,
      'display_name': v.displayName,
      'is_active': v.isActive ? 1 : 0,  //as db stores it as integer
      'fuel_type': v.fuelType,
      'model_no': v.modelNo,
      'vehicle_image': v.vehicleImage,

      'partner_id': v.partnerId,
      'vehicle_brand_id': v.vehicleBrandId,
      'vehicle_type_id': v.vehicleTypeId,

      'partner_json':
          v.partner != null ? jsonEncode(v.partner!.toJson()) : null,
      'vehicle_brand_json':
          v.vehicleBrand != null ? jsonEncode(v.vehicleBrand!.toJson()) : null,
      'vehicle_type_json':
          v.vehicleType != null ? jsonEncode(v.vehicleType!.toJson()) : null,
      'sync_status': syncStatus,
      'synced_at': DateTime.now().toIso8601String(),
    };
  }

  // For Dropdown options
  // cache partners in database from api
  Future<void> cachePartners(List<VehiclePartnerEmbed> partners) async{
    final db= await _db;
    await db.insert(
        'cached_partners',
        {
          'id':1, // list of partners is placed in single row
          'data': jsonEncode(partners.map((p)=>p.toJson()).toList()),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  //get cached partners from database
  Future<List<VehiclePartnerEmbed>> getCachedPartners() async{
    final db=await _db;
    final result = await db.query(
        'cached_partners',
        where: 'id = 1'
    );
    if(result.isEmpty) return [];
    final List<dynamic> data= jsonDecode(result.first['data'] as String);
    return data.map((json)=> VehiclePartnerEmbed.fromJson(json)).toList();
  }

  // Cache brands
  Future<void> cacheBrands(List<VehicleBrandEmbed> brands) async {
    final db = await _db;
    await db.insert(
      'cached_brands',
      {
        'id': 1,
        'data': jsonEncode(brands.map((b) => b.toJson()).toList()),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VehicleBrandEmbed>> getCachedBrands() async {
    final db = await _db;
    final result = await db.query('cached_brands', where: 'id = 1');
    if (result.isEmpty) return [];

    final List<dynamic> data = jsonDecode(result.first['data'] as String);
    return data.map((json) => VehicleBrandEmbed.fromJson(json)).toList();
  }

  // Cache types
  Future<void> cacheTypes(List<VehicleTypeEmbed> types) async {
    final db = await _db;
    await db.insert(
      'cached_types',
      {
        'id': 1,
        'data': jsonEncode(types.map((t) => t.toJson()).toList()),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VehicleTypeEmbed>> getCachedTypes() async {
    final db = await _db;
    final result = await db.query('cached_types', where: 'id = 1');
    if (result.isEmpty) return [];

    final List<dynamic> data = jsonDecode(result.first['data'] as String);
    return data.map((json) => VehicleTypeEmbed.fromJson(json)).toList();
  }

  // Helper methods to get FULL cached objects by ID
  Future<VehiclePartnerEmbed?> getPartnerById(int? id) async {
    if (id == null) return null;
    final partners = await getCachedPartners();
    try {
      return partners.firstWhere((p) => p.id == id);
    } catch (e) {
      print('Partner not found with id: $id');
      return null;
    }
  }

  Future<VehicleBrandEmbed?> getBrandById(int? id) async {
    if (id == null) return null;
    final brands = await getCachedBrands();
    try {
      return brands.firstWhere((b) => b.id == id);
    } catch (e) {
      print('Brand not found with id: $id');
      return null;
    }
  }

  Future<VehicleTypeEmbed?> getTypeById(int? id) async {
    if (id == null) return null;
    final types = await getCachedTypes();
    try {
      return types.firstWhere((t) => t.id == id);
    } catch (e) {
      print('Type not found with id: $id');
      return null;
    }
  }
}