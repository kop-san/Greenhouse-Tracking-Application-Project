import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BatchInfoCard extends StatelessWidget {
  final Map<String, dynamic> batch;
  final bool showPlantedDate;

  const BatchInfoCard({
    super.key,
    required this.batch,
    this.showPlantedDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batch ID: ${batch['id']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Product Type: ${batch['productType']}',
              style: const TextStyle(fontSize: 14),
            ),
            if (showPlantedDate && batch['plantedDate'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Planted Date: ${DateFormat('yyyy-MM-dd').format(batch['plantedDate'])}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (batch['greenhouse'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Greenhouse: ${batch['greenhouse']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 