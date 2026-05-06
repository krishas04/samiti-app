import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? errorText;
  final bool isLoading;

  const CustomDropdownFormField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.errorText,
    this.isLoading = false,
  });

  static final OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: AppColors.darkGrey),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label :',
            style: const TextStyle(),
          ),
          if (isLoading)
            Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkGrey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            DropdownButtonFormField<T>(
              initialValue: value,
              decoration: InputDecoration(
                hintText: "Select $label",
                errorText: errorText,
                enabledBorder: _border,
                focusedBorder: _border,
                focusedErrorBorder: _border,
                errorBorder: _border,
              ),
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.secondary),
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}