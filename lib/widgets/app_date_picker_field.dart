import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracking_app/constrants/app_colors.dart';

class AppDatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final String? labelText;
  final String? hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final void Function(DateTime?)? onDateSelected;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool isEnabled;
  final double borderRadius;

  const AppDatePickerField({
    super.key,
    required this.selectedDate,
    this.labelText,
    this.hintText,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.onDateSelected,
    this.validator,
    this.isRequired = false,
    this.isEnabled = true,
    this.borderRadius = 30.0,
  });

  Future<void> _pickDate(BuildContext context) async {
    if (!isEnabled) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initialDate ?? now,
      firstDate: firstDate ?? DateTime(now.year - 2),
      lastDate: lastDate ?? DateTime(now.year + 2),
    );

    if (picked != null && onDateSelected != null) {
      onDateSelected!(picked);
    }
  }

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
          readOnly: true,
          enabled: isEnabled,
          onTap: () => _pickDate(context),
          decoration: InputDecoration(
            hintText: hintText ?? 'Pick date',
            filled: true,
            fillColor: isEnabled ? AppColors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.calendar_today,
                size: 20,
              ),
              onPressed: isEnabled ? () => _pickDate(context) : null,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          controller: TextEditingController(
            text: selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                : '',
          ),
          validator: validator ??
              (isRequired
                  ? (value) {
                      if (selectedDate == null) {
                        return 'Please pick a date';
                      }
                      return null;
                    }
                  : null),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
