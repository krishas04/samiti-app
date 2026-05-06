import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/resusable_widgets/custom_appbar.dart';
import 'package:samiti_app/core/resusable_widgets/custom_text_field.dart';
import 'package:samiti_app/core/resusable_widgets/wide_elevated_button.dart';
import 'package:samiti_app/features/vehicle/model/vehicle_model.dart';
import 'package:samiti_app/features/vehicle/repository/vehicle_repository.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/resusable_widgets/custom_dropdown.dart';
import '../view_model/vehicle_view_model.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _vehicleNoController = TextEditingController();
  final _modelNoController = TextEditingController();


  VehiclePartnerEmbed? _selectedPartner;
  VehicleBrandEmbed? _selectedBrand;
  VehicleTypeEmbed? _selectedType;

  String? _selectedFuelType;
  File? _vehicleImage;
  String? _error;

  final _fuelTypes = ['diesel', 'petrol', 'electric'];
  final _picker = ImagePicker();

  // Dropdown option lists
  List<VehiclePartnerEmbed> _partners = [];
  List<VehicleBrandEmbed> _brands = [];
  List<VehicleTypeEmbed> _types = [];
  bool _loadingOptions = false;

  // Repository just for form dropdowns
  late final VehicleRepository _vehicleRepo;

  @override
  void initState() {
    super.initState();
    _vehicleRepo = VehicleRepository(client: sl());
    _loadDropdownOptions();
  }

  Future<void> _loadDropdownOptions() async {
    setState(() => _loadingOptions = true);
    try {
      final results = await Future.wait([
        _vehicleRepo.getPartners(),
        _vehicleRepo.getVehicleBrands(),
        _vehicleRepo.getVehicleTypes(),
      ]);
      setState(() {
        _partners = results[0] as List<VehiclePartnerEmbed>;
        _brands = results[1] as List<VehicleBrandEmbed>;
        _types = results[2] as List<VehicleTypeEmbed>;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load form options.');
    } finally {
      setState(() => _loadingOptions = false);
    }
  }

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
      // Send id, not display name
      if (_selectedPartner != null)
        'partner': _selectedPartner!.id.toString(),
      if (_selectedBrand != null)
        'vehicle_brand': _selectedBrand!.id.toString(),
      if (_selectedType != null)
        'vehicle_type': _selectedType!.id.toString(),
      if (_modelNoController.text.trim().isNotEmpty)
        'model_no': _modelNoController.text.trim(),
      if (_selectedFuelType != null) 'fuel_type': _selectedFuelType!,
    };

    final success = await context.read<VehicleViewModel>().createVehicle(
      fields: fields,
      imagePath: _vehicleImage?.path,
    );

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      final vm = context.read<VehicleViewModel>();
      setState(() => _error = vm.error);
    }
  }

  @override
  void dispose() {
    _vehicleNoController.dispose();
    _modelNoController.dispose();
    super.dispose();
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
            // Partner dropdown — shows display_name, sends id
            CustomDropdownFormField<VehiclePartnerEmbed>(
              label: 'Partner',
              value: _selectedPartner,
              items: _partners.map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.displayName),
              )).toList(),
              onChanged: (val) => setState(() => _selectedPartner = val),
              errorText: _error?.contains('Partner') == true ? _error : null,
            ),
            const SizedBox(height: 12),

            // For Vehicle Brand
            CustomDropdownFormField<VehicleBrandEmbed>(
              label: 'Vehicle Brand',
              value: _selectedBrand,
              items: _brands.map((b) => DropdownMenuItem(
                value: b,
                child: Text(b.displayName),
              )).toList(),
              onChanged: (val) => setState(() => _selectedBrand = val),
            ),
            const SizedBox(height: 12),

            // For Vehicle Type
            CustomDropdownFormField<VehicleTypeEmbed>(
              label: 'Vehicle Type',
              value: _selectedType,
              items: _types.map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.displayName),
              )).toList(),
              onChanged: (val) => setState(() => _selectedType = val),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _modelNoController,
              label: 'Model No',
            ),
            const SizedBox(height: 12),

            CustomDropdownFormField<String>(
              label: 'Fuel Type',
              value: _selectedFuelType,
              items: _fuelTypes.map((t) => DropdownMenuItem(
                value: t,
                child: Text(t),
              )).toList(),
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