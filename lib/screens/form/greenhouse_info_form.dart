import 'package:flutter/material.dart';
import '/constrants/app_colors.dart';
import '/widgets/app_text_field.dart';
import '/widgets/greenhouse_type_selector.dart';
import '/widgets/app_save_button.dart';
import '/services/greenhouse_service.dart';
import '/models/greenhouse.dart';

class GreenhouseInfoForm extends StatefulWidget {
  const GreenhouseInfoForm({super.key});

  @override
  State<GreenhouseInfoForm> createState() => _GreenhouseInfoFormState();
}

class _GreenhouseInfoFormState extends State<GreenhouseInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final _greenhouseService = GreenhouseService();

  GreenhouseType? _selectedType;
  bool _isLoading = false;
  List<Greenhouse> _existingGreenhouses = [];

  final List<Map<String, dynamic>> _types = [
    {
      'label': 'High Tunnel',
      'value': GreenhouseType.Tunel,
      'icon': Icons.architecture,
    },
    {
      'label': 'Saw Tooth',
      'value': GreenhouseType.Sawtooth,
      'icon': Icons.roofing,
    },
    {
      'label': 'Umbrella Vent',
      'value': GreenhouseType.Umbrella,
      'icon': Icons.account_balance
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingGreenhouses();
  }

  @override
  void dispose() {
    _idController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  bool _isValidGreenhouseId(String id) {
    final pattern = RegExp(r'^GAP-\d{2,3}$');
    return pattern.hasMatch(id);
  }

  String _generateNextGreenhouseId(List<Greenhouse> greenhouses) {
    if (greenhouses.isEmpty) {
      return 'GAP-001';
    }

    final ids = greenhouses
        .map((g) => int.tryParse(g.greenhouseId.replaceAll('GAP-', '')) ?? 0)
        .toList();
    final maxId = ids.reduce((a, b) => a > b ? a : b);
    return 'GAP-${(maxId + 1).toString().padLeft(3, '0')}';
  }

  Future<void> _loadExistingGreenhouses() async {
    try {
      final greenhouses = await _greenhouseService.getAllGreenhouses();
      setState(() {
        _existingGreenhouses = greenhouses;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading greenhouses: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final enteredId = _idController.text.trim();

    // Validate greenhouse ID format
    if (!_isValidGreenhouseId(enteredId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Greenhouse ID must be in format GAP-XX (e.g., GAP-01)')),
      );
      return;
    }

    // Check if ID already exists
    final existingId =
        _existingGreenhouses.any((gh) => gh.greenhouseId == enteredId);
    if (existingId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This Greenhouse ID already exists!')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Create greenhouse object
      final greenhouse = Greenhouse(
        greenhouseId: enteredId,
        type: _selectedType!,
        width: double.parse(_widthController.text),
        height: double.parse(_heightController.text),
        length: double.parse(_lengthController.text),
      );

      // Save to backend
      await _greenhouseService.createGreenhouse(greenhouse);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greenhouse created successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating greenhouse: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _generateNextId() {
    final nextId = _generateNextGreenhouseId(_existingGreenhouses);
    _idController.text = nextId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Greenhouse Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkPrimary,
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
              // Greenhouse ID field with generate button
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _idController,
                      labelText: 'Greenhouse ID',
                      hintText: 'e.g. GAP-01',
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Greenhouse ID is required';
                        }
                        if (!_isValidGreenhouseId(value.trim())) {
                          return 'ID must be in format GAP-XX';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48, // Match AppTextField height
                    child: ElevatedButton(
                      onPressed: _generateNextId,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text(
                        'Generate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Greenhouse Size',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              AppTextField(
                controller: _lengthController,
                labelText: 'Length (m)',
                hintText: 'Enter length',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Length is required';
                  }
                  final length = double.tryParse(value);
                  if (length == null || length <= 0) {
                    return 'Length must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _heightController,
                labelText: 'Height (m)',
                hintText: 'Enter height',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Height is required';
                  }
                  final height = double.tryParse(value);
                  if (height == null || height <= 0) {
                    return 'Height must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _widthController,
                labelText: 'Width (m)',
                hintText: 'Enter width',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Width is required';
                  }
                  final width = double.tryParse(value);
                  if (width == null || width <= 0) {
                    return 'Width must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GreenhouseTypeSelector(
                types: _types,
                selectedType: _selectedType,
                onTypeSelected: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 50),
              AppSaveButton(
                text: _isLoading ? 'Creating...' : 'Save',
                onPressed: _isLoading ? null : _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
