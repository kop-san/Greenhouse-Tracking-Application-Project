import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracking_app/constrants/app_colors.dart';
import 'package:tracking_app/models/greenhouse.dart';
import 'package:tracking_app/models/batch.dart';
import 'package:tracking_app/services/greenhouse_service.dart';
import 'package:tracking_app/services/batch_service.dart';
import 'package:tracking_app/services/api_service.dart';

class GreenhouseDetailsScreen extends StatefulWidget {
  final String greenhouseId;

  const GreenhouseDetailsScreen({super.key, required this.greenhouseId});

  @override
  State<GreenhouseDetailsScreen> createState() =>
      _GreenhouseDetailsScreenState();
}

class _GreenhouseDetailsScreenState extends State<GreenhouseDetailsScreen> {
  Greenhouse? _greenhouse;
  List<Batch> _batches = [];
  bool _isLoading = true;
  String? _error;
  final _greenhouseService = GreenhouseService();
  final _batchService = BatchService(ApiService());

  // Type info for display
  final Map<GreenhouseType, Map<String, dynamic>> _typeInfo = {
    GreenhouseType.Tunel: {
      'label': 'High Tunnel',
      'icon': Icons.architecture,
    },
    GreenhouseType.Sawtooth: {
      'label': 'Saw Tooth',
      'icon': Icons.roofing,
    },
    GreenhouseType.Umbrella: {
      'label': 'Umbrella Vent',
      'icon': Icons.account_balance,
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final greenhouse =
          await _greenhouseService.getGreenhouseById(widget.greenhouseId);
      final batchesJson = await _batchService.getAllBatches();
      final batches = batchesJson
          .map((json) => Batch.fromJson(json))
          .where((batch) => batch.greenhouseId == widget.greenhouseId)
          .toList();

      if (!mounted) return;
      setState(() {
        _greenhouse = greenhouse;
        _batches = batches;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildBatchCard(Batch batch) {
    final isHarvested = batch.harvested != null;
    final now = DateTime.now();
    final daysUntilHarvest = batch.expectedHarvest.difference(now).inDays;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Batch: ${batch.batchId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHarvested ? AppColors.success : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isHarvested ? 'Harvested' : 'Active',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Product: ${batch.product?.species ?? 'Unknown'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Planted: ${DateFormat('MMM dd, yyyy').format(batch.plantedDate)}',
              style: const TextStyle(fontSize: 14),
            ),
            if (!isHarvested) ...[
              const SizedBox(height: 4),
              Text(
                'Expected Harvest: ${DateFormat('MMM dd, yyyy').format(batch.expectedHarvest)}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Days until harvest: $daysUntilHarvest',
                style: TextStyle(
                  fontSize: 14,
                  color: daysUntilHarvest < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (isHarvested) ...[
              const SizedBox(height: 4),
              Text(
                'Total Weight: ${batch.harvested!.totalWeight}kg',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Grade A: ${batch.harvested!.gradeA}kg',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Grade B: ${batch.harvested!.gradeB}kg',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Waste: ${batch.harvested!.waste}kg',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Greenhouse Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _greenhouse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Greenhouse Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading greenhouse',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Greenhouse not found',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final greenhouse = _greenhouse!;
    final statusText = greenhouse.statusText;
    final statusColor = greenhouse.statusColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Greenhouse: ${greenhouse.greenhouseId}',
          style: const TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greenhouse Information Section
              const Text('Greenhouse Information',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'ID: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: greenhouse.greenhouseId),
                          ],
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Type: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: _typeInfo[greenhouse.type]?['label'] ??
                                  greenhouse.type.toString(),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Size: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  '${greenhouse.length}x${greenhouse.width}x${greenhouse.height} m',
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Area: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${greenhouse.area.toStringAsFixed(2)} m²',
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Volume: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  '${greenhouse.volume.toStringAsFixed(2)} m³',
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Health Status Section
              const Text('Health Status',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                color: statusColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor == AppColors.mild
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Batches Section
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Batches',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_batches.length} total',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_batches.isEmpty)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: const Center(
                      child: Text(
                        'No batches found for this greenhouse',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...(_batches
                      ..sort((a, b) => b.plantedDate.compareTo(a.plantedDate)))
                    .map(_buildBatchCard),
            ],
          ),
        ),
      ),
    );
  }
}
