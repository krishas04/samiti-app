import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/reusable_widgets/custom_appbar.dart';

import '../view_model/accident_view_model.dart';

class AccidentDetailScreen extends StatefulWidget {
  final int accidentId;
  const AccidentDetailScreen({super.key, required this.accidentId});

  @override
  State<AccidentDetailScreen> createState() => _AccidentDetailScreenState();
}

class _AccidentDetailScreenState extends State<AccidentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccidentViewModel>().fetchAccident(widget.accidentId);
    });
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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
    final vm = context.watch<AccidentViewModel>();
    final accident = vm.selectedAccident;

    return Scaffold(
      appBar: CustomAppBar(title: 'Accident Detail'),
      body: Builder(builder: (_) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.error != null) {
          return Center(child: Text(vm.error!));
        }
        if (accident == null) {
          return const Center(child: Text('No data.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('Name', accident.name),
                      const Divider(),
                      _infoRow('Vehicle', accident.vehicle?.vehicleNo),
                      _infoRow('Date', accident.accidentDate),
                      _infoRow('Driver', accident.driverName),
                      _infoRow('Place', accident.accidentPlace),
                      _infoRow('Cause', accident.accidentCause),
                      _infoRow('Remarks', accident.remarks),
                      _infoRow(
                          'Status', accident.isActive ? 'Active' : 'Inactive'),
                    ],
                  ),
                ),
              ),
              if (accident.images.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Images',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: accident.images.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        accident.images[index].image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}