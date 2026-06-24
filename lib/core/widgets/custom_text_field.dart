import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextDirection textDirection;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.textDirection = TextDirection.rtl,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: textDirection,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        textAlign: TextAlign.right,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: theme.textTheme.bodyMedium?.color,
        ),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffixIcon,
          prefixIcon: Icon(icon, color: theme.iconTheme.color),
        ),
      ),
    );
  }
}
