import 'package:flutter/material.dart';
import 'package:tracking_app/constrants/app_colors.dart';

class AppMultilineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool isEnabled;
  final bool showBorder;
  final double borderRadius;

  const AppMultilineTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.minLines = 2,
    this.maxLines = 4,
    this.validator,
    this.isRequired = false,
    this.isEnabled = true,
    this.showBorder = true,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          enabled: isEnabled,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: isEnabled ? AppColors.white : Colors.grey[100],
            border: showBorder ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ) : null,
            enabledBorder: showBorder ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ) : null,
            focusedBorder: showBorder ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ) : null,
            errorBorder: showBorder ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator ?? (isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
} 