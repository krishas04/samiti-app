import 'package:go_router/go_router.dart';
import 'package:samiti_app/features/auth/view/login_screen.dart';
import 'package:samiti_app/features/vehicle/view/vehicle_detail_screen.dart';
import 'package:samiti_app/features/vehicle/view/vehicle_form_screen.dart';
import 'package:samiti_app/features/vehicle/view/vehicle_list_screen.dart';

import '../../features/accident/view/accident_detail_screen.dart';
import '../../features/accident/view/accident_form_screen.dart';
import '../../features/accident/view/accident_list_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
      routes: [
        GoRoute(
            path: "/login",
            name: "login",
            builder:(context, state)=> const LoginScreen(),
        ),
        GoRoute(
            path: "/vehicles",
            name: "vehicles",
            builder:(context, state)=> const VehicleListScreen(),
            routes: [
              GoRoute(
                  path: "/add",
                  name:"vehicle-add",
                  builder: (context, state)=> const VehicleFormScreen(),
              ),
              GoRoute(
                  path: "/detail",
                  name:"vehicle-detail",
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return VehicleDetailScreen(vehicleId: id);
                  },
              ),
            ]
        ),
        GoRoute(
          path: '/accidents',
          name: 'accidents',
          builder: (context, state) => const AccidentListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'accident-add',
              builder: (context, state) => const AccidentFormScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'accident-detail',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return AccidentDetailScreen(accidentId: id);
              },
            ),
          ],
        ),
      ]
  );
}