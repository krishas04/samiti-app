import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/resusable_widgets/custom_appbar.dart';

import '../../../core/api/app_providers.dart';
import '../../../core/utils/token_storage.dart';
import '../view_model/accident_view_model.dart';
import 'accident_detail_screen.dart';
import 'accident_form_screen.dart';

class AccidentListScreen extends StatefulWidget {
  const AccidentListScreen({super.key});

  @override
  State<AccidentListScreen> createState() => _AccidentListScreenState();
}

class _AccidentListScreenState extends State<AccidentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccidentViewModel>().fetchAccidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccidentViewModel>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Accidents'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final token = await TokenStorage.getAccessToken();

          if (!mounted) return;

          Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AppProviders(
              token: token!,
              child: const AccidentFormScreen()
          )),
        ).then((_) {
            // Refresh list when returning from form
            if (mounted) {
              context.read<AccidentViewModel>().fetchAccidents();
            }
          });
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
                Text(vm.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: vm.fetchAccidents,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (vm.accidents.isEmpty) {
          return const Center(child: Text('No accidents found.'));
        }
        return RefreshIndicator(
          onRefresh: vm.fetchAccidents,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.accidents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final accident = vm.accidents[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.car_crash),
                  title: Text(accident.name),
                  subtitle: Text(
                    [
                      if (accident.vehicle?.vehicleNo != null)
                        accident.vehicle!.vehicleNo,
                      if (accident.driverName != null) accident.driverName!,
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async{
                    final token = await TokenStorage.getAccessToken();

                    if (!mounted) return;
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AppProviders(
                            token: token!,
                            child: AccidentDetailScreen(
                                accidentId: accident.id
                            ),
                          ),
                    ),
                  );}
                ),
              );
            },
          ),
        );
      }),
    );
  }
}