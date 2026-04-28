import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/resusable_widgets/custom_appbar.dart';
import 'package:samiti_app/core/resusable_widgets/custom_text_field.dart';
import 'package:samiti_app/core/resusable_widgets/wide_elevated_button.dart';

import '../../../core/constants/app_colors.dart';
import '../view_model/accident_view_model.dart';

class AccidentFormScreen extends StatefulWidget {
  const AccidentFormScreen({super.key});

  @override
  State<AccidentFormScreen> createState() => _AccidentFormScreenState();
}

class _AccidentFormScreenState extends State<AccidentFormScreen> {
  final _nameController = TextEditingController();
  final _vehicleIdController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _accidentDateController= TextEditingController();
  final _accidentPlaceController = TextEditingController();
  final _accidentCauseController = TextEditingController();
  final _remarksController = TextEditingController();

  final List<File> _images = [];
  String? _error;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _images.add(File(picked.path)));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      _accidentDateController.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Accident name is required.');
      return;
    }
    if (_vehicleIdController.text.trim().isEmpty) {
      setState(() => _error = 'Vehicle ID is required.');
      return;
    }
    setState(() => _error = null);

    final fields = <String, String>{
      'name': _nameController.text.trim(),
      'vehicle': _vehicleIdController.text.trim(),
      if (_driverNameController.text.trim().isNotEmpty)
        'driver_name': _driverNameController.text.trim(),
      if (_accidentDateController.text.trim().isNotEmpty)
        'accident_date': _accidentDateController.text.trim(),
      if (_accidentPlaceController.text.trim().isNotEmpty)
        'accident_place': _accidentPlaceController.text.trim(),
      if (_accidentCauseController.text.trim().isNotEmpty)
        'accident_cause': _accidentCauseController.text.trim(),
      if (_remarksController.text.trim().isNotEmpty)
        'remarks': _remarksController.text.trim(),
    };

    final success = await context.read<AccidentViewModel>().createAccident(
      fields: fields,
      imagePaths: _images.map((f) => f.path).toList(),
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => _error = context.read<AccidentViewModel>().error);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vehicleIdController.dispose();
    _driverNameController.dispose();
    _accidentDateController.dispose();
    _accidentPlaceController.dispose();
    _accidentCauseController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AccidentViewModel>().isLoading;

    return Scaffold(
      appBar: CustomAppBar(title: 'Add Accident'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(controller: _nameController, label: 'Name *'),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _vehicleIdController, label: 'Vehicle ID *'),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _driverNameController, label: 'Driver Name'),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _accidentPlaceController, label: 'Accident Place'),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _accidentCauseController, label: 'Accident Cause'),
            const SizedBox(height: 12),
            CustomTextField(controller: _remarksController, label: 'Remarks'),
            const SizedBox(height: 16),

            // Date field
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: _accidentDateController,
                  label: 'Accident Date',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Images
            const Text('Images',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._images.map((file) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file,
                          width: 100, height: 100, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _images.remove(file)),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.error,
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                )),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: AppColors.lightGrey),
                        SizedBox(height: 4),
                        Text('Add Image',
                            style:
                            TextStyle(fontSize: 11, color: AppColors.lightGrey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : WideElevatedButton(
                onPressed: _submit, text: 'Save Accident'),
          ],
        ),
      ),
    );
  }
}