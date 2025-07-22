import 'package:flutter/material.dart';
import 'package:tracking_app/models/user.dart';
import 'package:tracking_app/constrants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tracking_app/screens/form/disease_form.dart';
import 'package:tracking_app/models/disease.dart' as models;
import 'package:tracking_app/models/disease_infected.dart';
import 'package:tracking_app/models/greenhouse.dart';
import 'package:tracking_app/services/disease_service.dart';
import 'package:tracking_app/services/disease_infected_service.dart';
import 'package:tracking_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/screens/disease_detection_details.dart';

class DiseaseScreen extends StatefulWidget {
  final User user;
  const DiseaseScreen({super.key, required this.user});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  late final ApiService _apiService;
  late final DiseaseService _diseaseService;
  late final DiseaseInfectedService _diseaseInfectedService;
  bool _isInitialized = false;

  bool _isLoading = true;
  String? _error;

  List<models.Disease> _diseases = [];
  List<DiseaseInfected> _recentDetections = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _apiService = Provider.of<ApiService>(context, listen: false);
      _diseaseService = DiseaseService(_apiService);
      _diseaseInfectedService = DiseaseInfectedService(_apiService);
      _loadData();
      _isInitialized = true;
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _diseaseService.getAllDiseases(),
        _diseaseInfectedService.getAllDiseaseInfected(),
      ]);

      if (!mounted) return;

      setState(() {
        _diseases = List<models.Disease>.from(results[0] as List);
        _recentDetections = List<DiseaseInfected>.from(results[1] as List)
          ..sort((a, b) => b.detectedDate.compareTo(a.detectedDate));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recent Detections'),
              Tab(text: 'Disease Gallery'),
            ],
            labelColor: AppColors.darkPrimary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildRecentDetectionsTab(),
            _buildDiseaseGalleryTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DiseaseForm()),
            );
            if (result == true) {
              _loadData();
            }
          },
          backgroundColor: AppColors.primary,
          tooltip: 'Add New Disease',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRecentDetectionsTab() {
    if (_recentDetections.isEmpty) {
      return const Center(
        child: Text(
          'No disease detections found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _recentDetections.length,
        itemBuilder: (context, index) {
          final DiseaseInfected detection = _recentDetections[index];
          final models.Disease? disease = detection.disease;
          if (disease == null) return const SizedBox.shrink();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiseaseDetectionDetails(
                      detection: detection,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left side - Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: SizedBox(
                        width: 120,
                        child: detection.imageUrl != null
                            ? Image.network(
                                detection.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImageError(),
                              )
                            : _buildImageError(),
                      ),
                    ),
                    // Right side - Details
                    Expanded(
                      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                            Text(
                              disease.name,
                              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (detection.greenhouse != null)
                              Text(
                                'Greenhouse: ${detection.greenhouse!.greenhouseId}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(detection.detectedDate),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Add a subtle arrow icon to indicate it's clickable
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                  ),
                ),
              ],
            ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiseaseGalleryTab() {
    if (_diseases.isEmpty) {
      return const Center(
        child: Text(
          'No diseases found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _diseases.length,
              itemBuilder: (context, index) {
        final models.Disease disease = _diseases[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left side - Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 120,
                    child: disease.imageUrl != null
                        ? Image.network(
                            disease.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImageError(),
                          )
                        : _buildImageError(),
                  ),
                ),
                // Right side - Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          disease.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            disease.type.name.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (disease.description != null) ...[
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              disease.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Action Buttons
                        Row(
                          children: [
                            // Edit Button
                            TextButton.icon(
                              onPressed: () => _editDisease(disease),
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              label: const Text(
                                'Edit',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete Button
                            TextButton.icon(
                              onPressed: () => _confirmDelete(disease),
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(models.Disease disease) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${disease.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await _diseaseService.deleteDisease(disease.id);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disease deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Refresh the list
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete disease: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _editDisease(models.Disease disease) async {
    // Navigate to edit form
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseaseForm(disease: disease),
      ),
    );

    if (result == true && mounted) {
      _loadData(); // Refresh the list if changes were made
    }
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.lightPrimary,
      child: const Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
