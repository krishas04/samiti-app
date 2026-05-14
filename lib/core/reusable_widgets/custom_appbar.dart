import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final bool centerTitle;
  const CustomAppBar({super.key,required this.title, this.centerTitle=true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold)
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}