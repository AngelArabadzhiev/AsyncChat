
import 'package:flutter/material.dart';

import '../utils/brand_colors.dart';

class LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String type;
  final bool obscureTextEnabled;
  final Icon icon;
  final Icon? secondIcon;

  const LoginField(
      {super.key,
        required this.controller,
        required this.type,
        required this.obscureTextEnabled, required this.icon, this.secondIcon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        style: TextStyle(color: BrandColors.textColor),
        validator: (value) {
          if (value != null && value.isNotEmpty && value.length < 5) {
            return "Your $type must be longer than 5 characters!";
          } else if (value != null && value.isEmpty) {
            return "Please type your $type!";
          }
          return null;
        },
        controller: controller,
        obscureText: obscureTextEnabled,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),

          prefixIcon: icon,
          suffixIcon: secondIcon,
          hintText: type,
          hintStyle: TextStyle(
              color: Colors.black
          ),
        ));
  }
}