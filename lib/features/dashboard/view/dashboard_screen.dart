import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/reusable_widgets/custom_appbar.dart';
import 'package:samiti_app/core/reusable_widgets/custom_quick_action_tiles.dart';
import 'package:samiti_app/features/accident/view_model/accident_view_model.dart';
import 'package:samiti_app/features/vehicle/view_model/vehicle_view_model.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/reusable_widgets/custom_card.dart';
import '../../../core/reusable_widgets/section_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleViewModel>().fetchVehicles();
      context.read<AccidentViewModel>().fetchAccidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm=context.watch<VehicleViewModel>();
    final am=context.watch<AccidentViewModel>();

    final List<CustomItem> items =  [
      CustomItem(
        title: 'Vehicles',
        value: vm.vehicles.length.toString(),
        icon: Icons.directions_car,
        color: AppColors.blue,
        route: 'vehicles',
      ),
      CustomItem(
        title: 'Accidents',
        value: am.accidents.length.toString(),
        icon: Icons.car_crash,
        color: AppColors.blue,
        route: 'accidents',
      ),
    ];

    final List<CustomQuickActionTile> actions=[
      CustomQuickActionTile(
        label: 'Add vehicle',
        icon: Icons.add_circle_outline,
        color: AppColors.dark,
        onTap: ()=>context.goNamed('vehicle-add'),
      ),
      CustomQuickActionTile(
        label: 'Add accident',
        icon: Icons.add_circle_outline,
        color: AppColors.dark,
        onTap: ()=>context.goNamed('accident-add'),
      ),
    ];


    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1.Greeting container
              _buildGreetingContainer(),
              const SizedBox(height: 10,),
          
              // 2. Statistics Overview
              const SectionHeader(title: 'System Overview'),
              const SizedBox(height: 12),

              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: items.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return CustomCard(item: item);
                },
              ),
              const SizedBox(height: 12),
          
          
              // 3. Quick actions
              const SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 12),

              GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: actions.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final action= actions[index];
                    return action;
                  }
              ),

              // 4.Recent Vehicles section
              SectionHeader(
                title: 'Recent Vehicles',
                onSeeAll: () => context.pushNamed('vehicles'),
              ),
              _buildVehicleSection(vm),

              // 4.Recent Accidents section
              SectionHeader(
                title: 'Recent Accidents',
                onSeeAll: () => context.pushNamed('accidents'),
              ),
              _buildAccidentSection(am),
          
              ]
          ),
        ),
      ),
    );

  }

  Container _buildGreetingContainer() {
    return Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.dark,AppColors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkGrey,
                    blurRadius: 10,
                    offset: const Offset(0, 5)
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back',style: TextStyle(color: AppColors.white,fontWeight: FontWeight.w300),),
                  const SizedBox(height: 8,),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                    child: const Text('System Administrator', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            );
  }
}


Widget _buildVehicleSection(VehicleViewModel vm) {
  if (vm.isLoading && vm.vehicles.isEmpty) return const Center(child: CircularProgressIndicator());
  if (vm.vehicles.isEmpty) return const Center(child: Text("No vehicles found."));

  // We take only the latest 3 vehicles for the dashboard view
  final recentVehicles = vm.vehicles.take(3).toList();

  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: recentVehicles.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final vehicle = recentVehicles[index];
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
  );
}


Widget _buildAccidentSection(AccidentViewModel am) {
  if (am.isLoading && am.accidents.isEmpty) return const Center(child: CircularProgressIndicator());
  if (am.accidents.isEmpty) return const Center(child: Text("No accidents added."));

  // We take only the latest 3 vehicles for the dashboard view
  final recentAccidents = am.accidents.take(3).toList();

  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: recentAccidents.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final accident = recentAccidents[index];
      return Card(
        child: ListTile(
            leading: const Icon(Icons.car_crash_outlined),
            title: Text(accident.displayName),
            subtitle: Text(
              [
                if (accident.accidentDate != null)
                  accident.accidentDate!,
                if (accident.driverName != null) accident.driverName!,
              ].join(' · '),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async{
              await context.pushNamed(
                  "accident-detail",
                  pathParameters: {'id':accident.id.toString()}
              );
            }
        ),
      );
    },
  );
}