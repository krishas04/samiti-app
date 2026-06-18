import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:samiti_app/features/accident/repository/accident_repository.dart';
import 'package:samiti_app/features/accident/view_model/accident_view_model.dart';
import 'package:samiti_app/features/auth/repository/auth_repository.dart';
import 'package:samiti_app/features/auth/view_model/auth_view_model.dart';
import 'package:samiti_app/features/vehicle/repository/vehicle_repository.dart';
import 'package:samiti_app/features/vehicle/view_model/vehicle_view_model.dart';

import '../../features/accident/api/accident_api.dart';
import '../../features/accident/localdb/accident_local_db.dart';
import '../../features/vehicle/api/vehicle_api.dart';
import '../../features/vehicle/localdb/vehicle_local_db.dart';
import '../database/outbox_local_db.dart';
import '../network/connectivity_service.dart';
import '../sync/sync_engine.dart';
import '../utils/image_cache_helper.dart';

final sl = GetIt.instance;

void registerAuthFeature() {
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(client: sl<http.Client>()),
  );
  sl.registerLazySingleton<AuthViewModel>(
        () => AuthViewModel(repository: sl<AuthRepository>()),
  );
}

void registerVehicleFeature() {
  sl.registerLazySingleton<VehicleLocalDb>(() => VehicleLocalDb());
  sl.registerLazySingleton<VehicleApi>(
        () => VehicleApi(client: sl<http.Client>()),
  );

  sl.registerLazySingleton<VehicleRepository>(
        () => VehicleRepository(
      api: sl<VehicleApi>(),
      localDb: sl<VehicleLocalDb>(),
      outboxDb: sl<OutboxLocalDb>(),
      connectivity: sl<ConnectivityService>(),
    ),
  );
  sl.registerFactory<VehicleViewModel>(
        () => VehicleViewModel(
      repository: sl<VehicleRepository>(),
      syncEngine: sl<SyncEngine>(),
      connectivity: sl<ConnectivityService>(),
    ),
  );
}

void registerAccidentFeature() {
  sl.registerLazySingleton<AccidentLocalDb>(
          () => AccidentLocalDb()
  );
  sl.registerLazySingleton<AccidentApi>(
        () => AccidentApi(client: sl<http.Client>()),
  );
  sl.registerLazySingleton<AccidentRepository>(
        () => AccidentRepository(
          api:sl<AccidentApi>(),
          localDb: sl<AccidentLocalDb>(),
          outboxDb: sl<OutboxLocalDb>(),
          connectivity: sl<ConnectivityService>()
        ),
  );
  sl.registerFactory<AccidentViewModel>(
        () => AccidentViewModel(
          repository: sl<AccidentRepository>(),
          syncEngine: sl<SyncEngine>(),
          connectivity: sl<ConnectivityService>()
        ),
  );
}


void setupLocator() {
  // // Core infrastructure (singletons - live forever)
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  sl.registerLazySingleton<OutboxLocalDb>(() => OutboxLocalDb());
  sl.registerLazySingleton<ImageCacheHelper>(() => ImageCacheHelper());

  // Auth feature
  registerAuthFeature();

  // Vehicle feature
  registerVehicleFeature();

  // Accident feature
  registerAccidentFeature();

  // Register SyncEngine
  sl.registerLazySingleton<SyncEngine>(
        () => SyncEngine(
      vehicleApi: sl<VehicleApi>(),
      vehicleLocalDb: sl<VehicleLocalDb>(),
      accidentApi: sl<AccidentApi>(),
      accidentLocalDb: sl<AccidentLocalDb>(),
      outboxDb: sl<OutboxLocalDb>(),
    ),
  );
}