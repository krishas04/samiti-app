import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/resusable_widgets/custom_appbar.dart';

import '../../../core/constants/app_colors.dart';
import '../view_model/vehicle_view_model.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  @override
  void initState() {
    super.initState();
    // fetch after the first frame so the provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleViewModel>().fetchVehicles();
    });
  }


  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VehicleViewModel>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Vehicles'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          // Navigate to add screen, wait until user returns
          await context.pushNamed('vehicle-add');
          // Only after returning, refresh the list
          if(mounted) context.read<VehicleViewModel>().fetchVehicles();
          },
        child: const Icon(Icons.add),
      ),
      body: Builder(builder: (_) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(vm.error!, style: TextStyle(color: AppColors.error)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: vm.fetchVehicles,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (vm.vehicles.isEmpty) {
          return const Center(child: Text('No vehicles found.'));
        }
        return RefreshIndicator(
          onRefresh: vm.fetchVehicles,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final vehicle = vm.vehicles[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(vehicle.vehicleNo),
                  subtitle: Text(
                    [
                      if (vehicle.partner?.displayName != null)
                        vehicle.partner!.displayName,
                      if (vehicle.fuelType != null) vehicle.fuelType!,
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async{
                    await context.pushNamed(
                        "vehicle-detail",
                      pathParameters: {'id':vehicle.id.toString()}
                    );
                    }
                ),
              );
            },
          ),
        );
      }),
    );
  }
}