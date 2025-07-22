import 'package:flutter/material.dart';
import 'package:tracking_app/constrants/app_colors.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final T? Function(T)? itemValue;
  final void Function(T?)? onChanged;
  final String? hintText;
  final String? labelText;
  final String? Function(T?)? validator;
  final bool isRequired;
  final bool isEnabled;
  final double borderRadius;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    this.itemValue,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.validator,
    this.isRequired = false,
    this.isEnabled = true,
    this.borderRadius = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    // Validate that the value exists in items to prevent dropdown assertion error
    T? validValue = value;
    if (value != null) {
      final itemValues = items.map((item) => itemValue?.call(item) ?? item).toList();
      if (!itemValues.contains(value)) {
        validValue = null;
      }
    }

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
        DropdownButtonFormField<T>(
          value: validValue,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: itemValue?.call(item) ?? item,
                    child: Text(itemLabel(item)),
                  ))
              .toList(),
          onChanged: isEnabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: isEnabled ? AppColors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator ?? (isRequired ? (value) => value == null ? 'This field is required' : null : null),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
} 