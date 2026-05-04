import 'package:go_router/go_router.dart';
import 'package:samiti_app/core/utils/token_storage.dart';
import 'package:samiti_app/features/auth/view/login_screen.dart';
import 'package:samiti_app/features/auth/view/profile_screen.dart';
import 'package:samiti_app/features/dashboard/view/main_shell.dart';
import 'package:samiti_app/features/vehicle/view/vehicle_detail_screen.dart';
import 'package:samiti_app/features/vehicle/view/vehicle_form_screen.dart';
import 'package:samiti_app/features/vehicle/view/vehicle_list_screen.dart';

import '../../features/accident/view/accident_detail_screen.dart';
import '../../features/accident/view/accident_form_screen.dart';
import '../../features/accident/view/accident_list_screen.dart';
import '../../features/auth/view_model/auth_view_model.dart';
import '../../features/dashboard/view/dashboard_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
        initialLocation: '/login',
        refreshListenable: authViewModel, // ← re-evaluates redirect when auth changes
        redirect: (context, state) async {
          final hasToken = await TokenStorage.hasToken(); // returns bool
          final isLoginPage = state.matchedLocation == "/login"; //returns bool
          if (!hasToken && !isLoginPage) return "/login";
          if (hasToken && isLoginPage) return "/dashboard";
        },
        routes: [
          GoRoute(
            path: "/login",
            name: "login",
            builder: (context, state) => const LoginScreen(),
          ),
          ShellRoute(
              builder: (context, state, child) => MainShell(child: child),
              routes: [
                GoRoute(
                  path: '/dashboard',
                  name: 'dashboard',
                  builder: (context, state) => const DashboardScreen(),
                ),
                GoRoute(
                    path: "/vehicles",
                    name: "vehicles",
                    builder: (context, state) => const VehicleListScreen(),
                    routes: [
                      GoRoute(
                        path: "/add",
                        name: "vehicle-add",
                        builder: (context, state) => const VehicleFormScreen(),
                      ),
                      GoRoute(
                        path: ":id",
                        name: "vehicle-detail",
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
                GoRoute(
                  path: '/profile',
                  name: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ]
          )

        ]
    );
  }
}