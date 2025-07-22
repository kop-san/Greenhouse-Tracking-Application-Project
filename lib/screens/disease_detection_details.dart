import 'package:flutter/material.dart';
import 'package:tracking_app/constrants/app_colors.dart';
import 'package:tracking_app/models/disease_infected.dart';
import 'package:intl/intl.dart';

class DiseaseDetectionDetails extends StatelessWidget {
  final DiseaseInfected detection;

  const DiseaseDetectionDetails({
    super.key,
    required this.detection,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Disease Details',
          style: TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease Image
            if (detection.imageUrl != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withOpacity(0.1),
                ),
                child: Image.network(
                  detection.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Name and Type
                  if (detection.disease != null) ...[
                    Text(
                      detection.disease!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        detection.disease!.type.name.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Detection Information Section
                  _buildInfoSection(
                    title: 'Detection Information',
                    children: [
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Detected Date',
                        value: DateFormat('dd MMM yyyy')
                            .format(detection.detectedDate),
                      ),
                      if (detection.greenhouse != null)
                        _buildInfoRow(
                          icon: Icons.home_work,
                          label: 'Greenhouse',
                          value: detection.greenhouse!.greenhouseId,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Symptoms Section
                  if (detection.symptoms != null) ...[
                    _buildInfoSection(
                      title: 'Symptoms',
                      children: [
                        Text(
                          detection.symptoms!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Treatment Section
                  if (detection.treatmentNote != null) ...[
                    _buildInfoSection(
                      title: 'Treatment',
                      children: [
                        Text(
                          detection.treatmentNote!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Disease Description
                  if (detection.disease?.description != null) ...[
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      title: 'About This Disease',
                      children: [
                        Text(
                          detection.disease!.description!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
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

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
