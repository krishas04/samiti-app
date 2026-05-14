import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper{
  DbHelper._internal(); // private constructor - Nobody from outside can create instances
  static final DbHelper instance=DbHelper._internal();  // Db instance that follows singleton pattern; Singleton - Private constructor + Static instance = Only one instance ever exists

  static Database? _db;

  Future<Database> get database async{
    if(_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database?> initDb() async {
    final dbPath = await getDatabasesPath();  //getDatabasesPath() returns the path of the databases folder
    final path = join(dbPath,'samiti.db');  //returns path to the file

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch= db.batch();

    //vehicles table
    batch.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY,
        vehicle_no TEXT NOT NULL,
        display_name TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        fuel_type TEXT,
        partner_id INTEGER,
        vehicle_brand_id INTEGER,
        vehicle_type_id INTEGER,
        partner_json TEXT,
        vehicle_brand_json TEXT,
        vehicle_type_json TEXT,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        synced_at TEXT,
        model_no TEXT,
        engine_no TEXT,
        chasis_no TEXT,
        horse_power_cc TEXT,
        billbook_no TEXT,
        billbook_expire_date TEXT,  
        billbook_image TEXT,  
        vehicle_image TEXT,  
        manufacture_year INTEGER,
        registration_date TEXT,
        previous_vehicle_no TEXT,
        additional_info TEXT,
        remarks TEXT
      )
    '''
    );

    // accidents table
    batch.execute('''
      CREATE TABLE accidents (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        display_name TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        accident_date TEXT,
        driver_name TEXT,
        accident_place TEXT,
        accident_cause TEXT,
        effect_others INTEGER,
        having_death INTEGER,
        no_of_death INTEGER,
        application_amount TEXT,
        additional_info TEXT,
        remarks TEXT,
        vehicle_json TEXT,
        images_json TEXT,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        synced_at TEXT
      )
    ''');

    //outbox table
    batch.execute('''
      CREATE TABLE outbox (
        id TEXT PRIMARY KEY,
        operation TEXT NOT NULL,  --//'create', 'update', 'delete'
        resource TEXT NOT NULL,   --//'vehicles', 'accidents'
        endpoint TEXT NOT NULL,   --//'POST', 'PUT', 'DELETE'
        payload TEXT NOT NULL,
        method TEXT NOT NULL,
        pending_image_path TEXT,
        retry_count INTEGER NOT NULL DEFAULT 0,
        max_retries INTEGER NOT NULL DEFAULT 3,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',   --//'pending', 'processing', 'failed'
        last_error TEXT
      )
    ''');

    //cached_partners table
    batch.execute('''
      CREATE TABLE cached_partners(
        id INTEGER PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // cached_brands table
    batch.execute('''
      CREATE TABLE cached_brands (
      id INTEGER PRIMARY KEY,
      data TEXT NOT NULL,
      updated_at TEXT NOT NULL
      )
    ''');

    // cached_types table
    batch.execute('''
      CREATE TABLE cached_types (
      id INTEGER PRIMARY KEY,
      data TEXT NOT NULL,
      updated_at TEXT NOT NULL
      )
    ''');

    await batch.commit(noResult: true);

  }
}