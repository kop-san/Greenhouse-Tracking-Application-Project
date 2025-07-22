import 'package:flutter/material.dart';
import 'package:tracking_app/constrants/app_colors.dart';
import 'package:tracking_app/models/greenhouse.dart';

class GreenhouseCard extends StatelessWidget {
  final Greenhouse greenhouse;

  const GreenhouseCard({
    super.key,
    required this.greenhouse,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = greenhouse.statusColor;
    final statusText = greenhouse.statusText;

    return Card(
      color: statusColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.house_rounded,
                size: 80,
                color: statusColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greenhouse.greenhouseId,
                  style: TextStyle(
                    color: statusColor == AppColors.mild
                        ? Colors.black
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  greenhouse.type.toString().split('.').last,
                  style: TextStyle(
                    color: statusColor == AppColors.mild
                        ? Colors.black
                        : Colors.white,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor == AppColors.mild
                          ? Colors.black
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
