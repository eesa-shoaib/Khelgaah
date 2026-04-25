import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
