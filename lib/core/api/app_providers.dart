
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:samiti_app/features/vehicle/repository/vehicle_repository.dart';
import 'package:samiti_app/features/vehicle/view_model/vehicle_view_model.dart';

import '../../features/accident/repository/accident_repository.dart';
import '../../features/accident/view_model/accident_view_model.dart';
import '../di/service_locator.dart';
import '../network/connectivity_service.dart';
import '../sync/sync_engine.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // it shares existing singleton instance of ConnectivityService from GetIt across the entire app
        ChangeNotifierProvider.value(value: sl<ConnectivityService>()),
        ChangeNotifierProvider(
          create: (_) => VehicleViewModel(
          repository: sl<VehicleRepository>(),
          syncEngine: sl<SyncEngine>(),
          connectivity: sl<ConnectivityService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AccidentViewModel(
            repository: AccidentRepository(client: sl<http.Client>()),
          ),
        ),
      ],
      child: child,
    );
  }
}