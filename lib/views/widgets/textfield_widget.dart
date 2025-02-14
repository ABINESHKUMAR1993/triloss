import 'package:flutter/material.dart';

import '../../constants/main_colors.dart';


class CustomTextField extends StatefulWidget {
  final bool obscureText;
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const CustomTextField({
    super.key,
    this.obscureText = false,
    required this.controller,
    this.hintText = '',
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey,
          ), // Set hint text color to grey
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              8,
            ), // Optional: Add border radius
            borderSide: BorderSide(
              color: Colors.grey,
            ), // Set the default border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: cPrimaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          prefixIcon: widget.prefixIcon,
          suffixIcon:
              widget.obscureText
                  ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }
}
