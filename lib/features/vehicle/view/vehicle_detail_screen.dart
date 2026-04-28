import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/resusable_widgets/custom_appbar.dart';

import '../view_model/vehicle_view_model.dart';

class VehicleDetailScreen extends StatefulWidget {
  final int vehicleId;
  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleViewModel>().fetchVehicle(widget.vehicleId);
    });
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value ?? '—')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VehicleViewModel>();
    final vehicle = vm.selectedVehicle;

    return Scaffold(
      appBar: CustomAppBar(title: 'Vehicle Detail'),
      body: Builder(builder: (_) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.error != null) {
          return Center(child: Text(vm.error!));
        }
        if (vehicle == null) {
          return const Center(child: Text('No data.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: vehicle.vehicleImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(vehicle.vehicleImage!, fit: BoxFit.cover),
                    )
                        : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40, color: Colors.grey),

                      ],
                    ),
                  ),
                  _infoRow('Vehicle No', vehicle.vehicleNo),
                  const Divider(),
                  _infoRow('Partner', vehicle.partner?.displayName),
                  _infoRow('Fuel Type', vehicle.fuelType),
                  _infoRow('Model No', vehicle.modelNo),
                  _infoRow('Status', vehicle.isActive ? 'Active' : 'Inactive'),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}