import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class WideElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backGroundColor;
  final Color textColor;

  const WideElevatedButton({super.key,required this.text,this.onPressed,this.backGroundColor=AppColors.lightGrey, this.textColor=AppColors.greyBlack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: backGroundColor,
            foregroundColor: textColor,
            side: BorderSide(
                color: AppColors.secondary,
                width:0.15 )
        ),
        child: Text(text),
      ),
    );
  }
}
