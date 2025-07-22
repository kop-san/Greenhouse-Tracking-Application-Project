import 'package:flutter/material.dart';
import 'package:tracking_app/constrants/app_colors.dart';
import 'package:tracking_app/models/greenhouse.dart';

class GreenhouseTypeSelector extends StatelessWidget {
  final List<Map<String, dynamic>> types;
  final GreenhouseType? selectedType;
  final void Function(GreenhouseType) onTypeSelected;
  final int crossAxisCount;
  final double itemWidth;
  final double itemHeight;

  const GreenhouseTypeSelector({
    super.key,
    required this.types,
    required this.selectedType,
    required this.onTypeSelected,
    this.crossAxisCount = 3,
    this.itemWidth = 100,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: types.map((type) {
            final isSelected = selectedType == type['value'];
            return GestureDetector(
              onTap: () => onTypeSelected(type['value']),
              child: Container(
                width: itemWidth,
                height: itemHeight,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type['icon'],
                      size: 36,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type['label'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
} 