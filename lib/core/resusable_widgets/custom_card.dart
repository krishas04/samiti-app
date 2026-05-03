import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final CustomItem item;
  const CustomCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.pushNamed(item.route),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withAlpha(25),  // alpha chanel sets the transparency using an integer between 0 (fully transparent) and 255 (fully opaque).
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 25, color: item.color),
              ),
              Text(
                item.value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey
                ),
              ),
              Text(
                item.title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String route;

  const CustomItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.route,
  });
}