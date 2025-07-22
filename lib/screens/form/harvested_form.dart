import 'package:flutter/material.dart';
import '/constrants/app_colors.dart';
import '/models/harvested.dart';
import '/models/batch.dart';
import '/services/batch_service.dart';
import '/services/harvested_service.dart';
import '/widgets/app_dropdown.dart';
import '/widgets/app_text_field.dart';
import '/widgets/app_multiline_text_field.dart';
import '/widgets/app_save_button.dart';
import '/widgets/batch_info_card.dart';
import '/services/api_service.dart';

class HarvestedForm extends StatefulWidget {
  const HarvestedForm({super.key});

  @override
  State<HarvestedForm> createState() => _HarvestedFormState();
}

class _HarvestedFormState extends State<HarvestedForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late final _batchService = BatchService(_apiService);
  final _harvestedService = HarvestedService();

  List<Batch> _batches = [];
  bool _isLoading = true;
  String? _error;

  String? _selectedBatchId;
  Batch? _selectedBatch;

  final _totalWeightController = TextEditingController();
  final _gradeAController = TextEditingController();
  final _gradeBController = TextEditingController();
  final _wasteController = TextEditingController();

  HarvestStatus? _harvestStatus;
  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Completed', 'value': HarvestStatus.Completed},
    {'label': 'Pending', 'value': HarvestStatus.Pending},
  ];

  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _batchService.getAllBatches();
      final batches = response
          .map((json) => Batch.fromJson(json))
          .where((batch) =>
              batch.harvested == null ||
              batch.harvested!.status != HarvestStatus.Completed)
          .toList();

      if (!mounted) return;
      setState(() {
        _batches = batches;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load batches: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _totalWeightController.dispose();
    _gradeAController.dispose();
    _gradeBController.dispose();
    _wasteController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onBatchChanged(String? id) {
    setState(() {
      _selectedBatchId = id;
      _selectedBatch = _batches.firstWhere(
        (batch) => batch.batchId == id,
        orElse: () => _batches.first,
      );
      _harvestStatus = HarvestStatus.Pending;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedBatch == null ||
        _harvestStatus == null) {
      if (_selectedBatch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a batch.')),
        );
      } else if (_harvestStatus == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select harvest status.')),
        );
      }
      return;
    }

    try {
      final gradeA = double.parse(_gradeAController.text);
      final gradeB = double.parse(_gradeBController.text);
      final waste = double.parse(_wasteController.text);
      final totalWeight = double.parse(_totalWeightController.text);

      await _harvestedService.createHarvested(
        gradeA: gradeA,
        gradeB: gradeB,
        waste: waste,
        totalWeight: totalWeight,
        status: _harvestStatus!,
        batchId: _selectedBatchId!,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harvest record saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving harvest record: $e')),
        );
      }
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
                onPressed: _loadBatches,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Harvested Form',
          style: TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDropdown<Batch>(
                value: _selectedBatch,
                items: _batches,
                itemLabel: (batch) => '${batch.batchId}',
                itemValue: (batch) => batch,
                onChanged: (batch) => _onBatchChanged(batch?.batchId),
                labelText: 'Batch',
                hintText: 'Select batch',
                isRequired: true,
              ),
              if (_selectedBatch != null) ...[
                const SizedBox(height: 16),
                BatchInfoCard(
                  batch: {
                    'id': _selectedBatch!.batchId,
                    'productType': _selectedBatch!.productId,
                    'plantedDate': _selectedBatch!.plantedDate,
                    'greenhouse': _selectedBatch!.greenhouseId,
                  },
                  showPlantedDate: true,
                ),
              ],
              const SizedBox(height: 24),
              const Text('Harvest Results',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
              const SizedBox(height: 16),
              AppTextField(
                controller: _totalWeightController,
                labelText: 'Total Weight (kg)',
                hintText: 'Enter total weight',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _gradeAController,
                      labelText: 'Grade A (kg)',
                      hintText: 'Grade A',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      controller: _gradeBController,
                      labelText: 'Grade B (kg)',
                      hintText: 'Grade B',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      controller: _wasteController,
                      labelText: 'Waste (kg)',
                      hintText: 'Waste',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppDropdown<Map<String, dynamic>>(
                value: _harvestStatus != null
                    ? _statusOptions.firstWhere(
                        (opt) => opt['value'] == _harvestStatus,
                        orElse: () => _statusOptions.first,
                      )
                    : null,
                items: _statusOptions,
                itemLabel: (opt) => opt['label'] as String,
                itemValue: (opt) => opt,
                onChanged: (val) => setState(
                    () => _harvestStatus = val?['value'] as HarvestStatus?),
                labelText: 'Harvest Status',
                hintText: 'Select status',
                isRequired: true,
              ),
              const SizedBox(height: 24),
              AppMultilineTextField(
                controller: _noteController,
                labelText: 'Note (optional)',
                hintText: 'Enter note',
              ),
              const SizedBox(height: 32),
              AppSaveButton(
                text: 'Save',
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
