import 'package:flutter/material.dart';
import 'package:tracking_app/constrants/app_colors.dart';
import '../models/greenhouse.dart';
import 'package:intl/intl.dart';

class GreenhouseInfoCard extends StatelessWidget {
  final Greenhouse greenhouse;
  final bool showBatches;

  const GreenhouseInfoCard({
    super.key,
    required this.greenhouse,
    this.showBatches = false,
  });

  IconData _getTypeIcon(GreenhouseType type) {
    switch (type) {
      case GreenhouseType.Tunel:
        return Icons.architecture;
      case GreenhouseType.Sawtooth:
        return Icons.roofing;
      case GreenhouseType.Umbrella:
        return Icons.account_balance;
    }
  }

  String _getTypeLabel(GreenhouseType type) {
    switch (type) {
      case GreenhouseType.Tunel:
        return 'High Tunnel';
      case GreenhouseType.Sawtooth:
        return 'Saw Tooth';
      case GreenhouseType.Umbrella:
        return 'Umbrella Vent';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeBatch = greenhouse.activeBatch;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getTypeIcon(greenhouse.type),
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${greenhouse.greenhouseId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${_getTypeLabel(greenhouse.type)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size: ${greenhouse.length} x ${greenhouse.width} x ${greenhouse.height} m',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (showBatches) ...[
                    const SizedBox(height: 12),
                    if (activeBatch != null) ...[
                      const Text(
                        'Active Batch:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Product: ${activeBatch.productName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Planted: ${DateFormat('yyyy-MM-dd').format(activeBatch.plantedDate)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ] else
                      const Text(
                        'No active batch',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
