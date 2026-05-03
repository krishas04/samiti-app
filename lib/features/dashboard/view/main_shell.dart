import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  // a helper method that decides which tab in your NavigationBar should be highlighted
  // based on the current route
  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation; //current route
    if (location.startsWith('/vehicles')) return 1;
    if (location.startsWith('/accidents')) return 2;
    return 0; // dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.goNamed('dashboard');
              break;
            case 1:
              context.goNamed('vehicles');
              break;
            case 2:
              context.goNamed('accidents');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Vehicles',
          ),
          NavigationDestination(
            icon: Icon(Icons.car_crash_outlined),
            selectedIcon: Icon(Icons.car_crash),
            label: 'Accidents',
          ),
        ],
      ),
    );
  }
}