import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:samiti_app/features/accident/repository/accident_repository.dart';
import 'package:samiti_app/features/accident/view_model/accident_view_model.dart';
import 'package:samiti_app/features/auth/repository/auth_repository.dart';
import 'package:samiti_app/features/auth/view_model/auth_view_model.dart';
import 'package:samiti_app/features/vehicle/repository/vehicle_repository.dart';
import 'package:samiti_app/features/vehicle/view_model/vehicle_view_model.dart';

import '../../features/vehicle/api/vehicle_api.dart';
import '../../features/vehicle/localdb/vehicle_local_db.dart';
import '../database/outbox_local_db.dart';
import '../network/connectivity_service.dart';
import '../sync/sync_engine.dart';

final sl = GetIt.instance;

void registerAuthFeature() {
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(client: sl<http.Client>()),
  );
  sl.registerLazySingleton<AuthViewModel>(
        () => AuthViewModel(repository: sl<AuthRepository>()),
  );
}

void registerVehicleFeature(String? token) {
  sl.registerLazySingleton<VehicleLocalDb>(() => VehicleLocalDb());
  sl.registerLazySingleton<VehicleApi>(
        () => VehicleApi(client: sl<http.Client>()),
  );
  sl.registerLazySingleton<SyncEngine>(
        () => SyncEngine(
      vehicleApi: sl<VehicleApi>(),
      vehicleLocalDb: sl<VehicleLocalDb>(),
      outboxDb: sl<OutboxLocalDb>(),
    ),
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

void registerAccidentFeature(String? token) {
  // Use registerFactory so a fresh token is always used
  sl.registerFactory<AccidentRepository>(
        () => AccidentRepository(client: sl<http.Client>()),
  );
  sl.registerFactory<AccidentViewModel>(
        () => AccidentViewModel(repository: sl<AccidentRepository>(), ),
  );
}


void setupLocator() {
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  sl.registerLazySingleton<OutboxLocalDb>(() => OutboxLocalDb());
  registerAuthFeature();
  registerVehicleFeature('');
  registerAccidentFeature('');
  // Vehicle and Accident are registered after login (token required).
  // Call registerVehicleFeature(token) and registerAccidentFeature(token)
  // from AuthViewModel after a successful login.
}