import 'package:flutter/material.dart';

class AppStatusButtonGrid<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final void Function(T) onSelected;
  final String Function(T) getLabel;
  final Color Function(T) getColor;
  final int crossAxisCount;
  final double height;
  final double childAspectRatio;

  const AppStatusButtonGrid({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    required this.getLabel,
    required this.getColor,
    this.crossAxisCount = 2,
    this.height = 110,
    this.childAspectRatio = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: childAspectRatio,
        physics: const NeverScrollableScrollPhysics(),
        children: items.map((item) {
          final isSelected = selectedItem == item;
          final color = getColor(item);
          final label = getLabel(item);
          
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? color : Colors.grey[200],
              foregroundColor: isSelected
                  ? (color == Colors.orange ? Colors.black : Colors.white)
                  : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => onSelected(item),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 