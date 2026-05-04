import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:samiti_app/features/accident/repository/accident_repository.dart';
import 'package:samiti_app/features/accident/view_model/accident_view_model.dart';
import 'package:samiti_app/features/auth/repository/auth_repository.dart';
import 'package:samiti_app/features/auth/view_model/auth_view_model.dart';
import 'package:samiti_app/features/vehicle/repository/vehicle_repository.dart';
import 'package:samiti_app/features/vehicle/view_model/vehicle_view_model.dart';

final sl = GetIt.instance;

void registerAuthFeature() {
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(client: sl<http.Client>()),
  );
  sl.registerLazySingleton<AuthViewModel>(
        () => AuthViewModel(repository: sl<AuthRepository>()),
  );
}

void registerVehicleFeature(String token) {
  // Use registerFactory so a fresh token is always used
  sl.registerFactory<VehicleRepository>(
        () => VehicleRepository(client: sl<http.Client>()),
  );
  sl.registerFactory<VehicleViewModel>(
        () => VehicleViewModel(repository: sl<VehicleRepository>(), ),
  );
}

void registerAccidentFeature(String token) {
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
  registerAuthFeature();
  // Vehicle and Accident are registered after login (token required).
  // Call registerVehicleFeature(token) and registerAccidentFeature(token)
  // from AuthViewModel after a successful login.
}