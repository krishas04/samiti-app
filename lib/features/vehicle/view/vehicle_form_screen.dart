import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/resusable_widgets/custom_appbar.dart';
import 'package:samiti_app/core/resusable_widgets/custom_text_field.dart';
import 'package:samiti_app/core/resusable_widgets/wide_elevated_button.dart';

import '../../../core/constants/app_colors.dart';
import '../view_model/vehicle_view_model.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _vehicleNoController = TextEditingController();
  final _partnerController = TextEditingController();
  final _vehicleBrandController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _modelNoController = TextEditingController();

  String? _selectedFuelType;
  File? _vehicleImage;
  String? _error;

  final _fuelTypes = ['diesel', 'petrol', 'electric'];
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _vehicleImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_vehicleNoController.text.trim().isEmpty) {
      setState(() => _error = 'Vehicle number is required.');
      return;
    }
    setState(() => _error = null);

    final fields = <String, String>{
      'vehicle_no': _vehicleNoController.text.trim(),
      if (_partnerController.text.trim().isNotEmpty)
        'partner': _partnerController.text.trim(),
      if (_vehicleBrandController.text.trim().isNotEmpty)
        'vehicle_brand': _vehicleBrandController.text.trim(),
      if (_vehicleTypeController.text.trim().isNotEmpty)
        'vehicle_type': _vehicleTypeController.text.trim(),
      if (_modelNoController.text.trim().isNotEmpty)
        'model_no': _modelNoController.text.trim(),
      if (_selectedFuelType != null) 'fuel_type': _selectedFuelType!,
    };

    final success = await context.read<VehicleViewModel>().createVehicle(
      fields: fields,
      imagePath: _vehicleImage?.path,
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      final vm = context.read<VehicleViewModel>();
      setState(() => _error = vm.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<VehicleViewModel>().isLoading;

    return Scaffold(
      appBar: CustomAppBar(title: 'Add Vehicle'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _vehicleNoController,
              label: 'Vehicle Number *',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _partnerController,
              label: 'Partner ID',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _vehicleBrandController,
              label: 'Vehicle Brand ID',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _vehicleTypeController,
              label: 'Vehicle Type ID',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _modelNoController,
              label: 'Model No',
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedFuelType,
              decoration: const InputDecoration(
                labelText: 'Fuel Type',
                border: OutlineInputBorder(),
              ),
              items: _fuelTypes
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedFuelType = val),
            ),
            const SizedBox(height: 16),
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _vehicleImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_vehicleImage!, fit: BoxFit.cover),
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 40, color: AppColors.lightGrey),
                    SizedBox(height: 8),
                    Text('Tap to add vehicle image',
                        style: TextStyle(color: AppColors.lightGrey)),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : WideElevatedButton(onPressed: _submit, text: 'Save Vehicle'),
          ],
        ),
      ),
    );
  }
}