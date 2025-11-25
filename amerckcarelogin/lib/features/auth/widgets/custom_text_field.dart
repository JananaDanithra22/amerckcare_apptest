import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final double borderRadius;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.obscureText = false,
    this.onToggleVisibility,
    this.onChanged,
    this.keyboardType,
    this.borderRadius = 12.0, required String? Function(dynamic value) validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(196, 238, 238, 238),
            borderRadius: BorderRadius.circular(borderRadius),
            border:
                errorText != null
                    ? Border.all(color: Colors.red, width: 1.5)
                    : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 18, color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              suffixIcon:
                  onToggleVisibility != null
                      ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: onToggleVisibility,
                      )
                      : null,
            ),
            onChanged: onChanged,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
