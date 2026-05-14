import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? type;
  final String? Function(String?)? validator;
  final bool isPassword;
  final String? errorText;
  const CustomTextField({super.key, required this.controller,required this.label,this.type, this.validator, this.isPassword=false,this.errorText});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();

  static final OutlineInputBorder buildOutlineInputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
          color: AppColors.darkGrey
      )
  );
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText= true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.label} :',
            style: TextStyle(),
          ),
          TextFormField(
            controller:widget.controller,
            decoration: InputDecoration(
              hintText: widget.isPassword?'********':"Enter your ${widget.label.toLowerCase()}",
              errorText: widget.errorText,
              enabledBorder: CustomTextField.buildOutlineInputBorder,
              focusedBorder:  CustomTextField.buildOutlineInputBorder,
              focusedErrorBorder: CustomTextField.buildOutlineInputBorder,
              errorBorder: CustomTextField.buildOutlineInputBorder,
              suffixIcon: widget.isPassword
                  ?IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.secondary,
                ),
                onPressed: (){
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },)
                  : null,
            ),
            keyboardType: widget.type,
            obscureText: widget.isPassword? _obscureText:false,
            validator:(value){
              return widget.validator!(value);
            },
          ),
        ],
      ),
    );
  }
}
