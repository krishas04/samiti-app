
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/features/vehicle/repository/vehicle_repository.dart';
import 'package:samiti_app/features/vehicle/view_model/vehicle_view_model.dart';

import '../../features/accident/repository/accident_repository.dart';
import '../../features/accident/view_model/accident_view_model.dart';
import '../di/service_locator.dart';

class AppProviders extends StatelessWidget {
  final String token;
  final Widget child;

  const AppProviders({super.key, required this.token, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VehicleViewModel(
            repository: VehicleRepository(client: sl()),
            token: token,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AccidentViewModel(
            repository: AccidentRepository(client: sl()),
          ),
        ),
      ],
      child: child,
    );
  }
}