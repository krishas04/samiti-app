import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See all', style: TextStyle(color: AppColors.primary))),
      ],
    );
  }
}