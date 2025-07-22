import 'package:flutter/material.dart';
import 'package:tracking_app/constrants/app_colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool isEnabled;
  final bool showBorder;
  final int? maxLines;
  final int? minLines;
  final double borderRadius;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.isRequired = false,
    this.isEnabled = true,
    this.showBorder = true,
    this.maxLines,
    this.minLines,
    this.borderRadius = 30.0,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          enabled: widget.isEnabled,
          maxLines: widget.maxLines ?? (widget.isPassword ? 1 : null),
          minLines: widget.minLines,
          validator: widget.validator ?? (widget.isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppColors.black.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: widget.isEnabled ? AppColors.white : Colors.grey[100],
            prefixIcon: widget.prefixIcon != null ? Icon(
              widget.prefixIcon,
              color: AppColors.primary.withValues(alpha: 0.7),
              size: 20,
            ) : null,
            border: widget.showBorder ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ) : null,
            enabledBorder: widget.showBorder ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ) : null,
            focusedBorder: widget.showBorder ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ) : null,
            errorBorder: widget.showBorder ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ) : null,
            focusedErrorBorder: widget.showBorder ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12, // Compact padding for form fields
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.black.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
} 