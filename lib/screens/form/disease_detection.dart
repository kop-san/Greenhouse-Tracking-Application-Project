import 'package:flutter/material.dart';
import '/constrants/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '/models/disease.dart';
import '/models/greenhouse.dart';
import '/services/disease_service.dart';
import '/services/greenhouse_service.dart';
import '/services/disease_infected_service.dart';
import '/services/image_service.dart';
import '/services/api_service.dart';
import '/services/auth_service.dart';
import '/widgets/app_dropdown.dart';
import '/widgets/app_multiline_text_field.dart';
import '/widgets/app_date_picker_field.dart';
import '/widgets/app_save_button.dart';
import '/widgets/greenhouse_info_card.dart';
import 'disease_form.dart';
import 'package:provider/provider.dart';

class DiseaseDetectionForm extends StatefulWidget {
  const DiseaseDetectionForm({super.key});

  @override
  State<DiseaseDetectionForm> createState() => _DiseaseDetectionFormState();
}

class _DiseaseDetectionFormState extends State<DiseaseDetectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late final _diseaseService = DiseaseService(_apiService);
  late final _greenhouseService = GreenhouseService(apiService: _apiService);
  late final _diseaseInfectedService = DiseaseInfectedService(_apiService);
  late ImageService _imageService;

  bool _isLoading = true;
  bool _isInitialized = false;
  List<Disease> _diseases = [];
  List<Greenhouse> _greenhouses = [];

  // Selected items
  Greenhouse? _selectedGreenhouse;
  Disease? _selectedDisease;

  // Image
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Detected date
  DateTime _detectedDate = DateTime.now();

  final _symptomController = TextEditingController();
  final _treatmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _imageService =
          ImageService(apiService: _apiService, authService: authService);
      _loadData();
      _isInitialized = true;
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // Load both greenhouses and diseases in parallel
      final results = await Future.wait([
        _greenhouseService.getAllGreenhouses(),
        _diseaseService.getAllDiseases(),
      ]);

      setState(() {
        _greenhouses = results[0] as List<Greenhouse>;
        _diseases = results[1] as List<Disease>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _treatmentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final imageFile = await _imageService.pickImage(source: source);
      if (imageFile != null) {
        setState(() {
          _imageFile = imageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _navigateToAddDisease() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiseaseForm()),
    );

    if (result == true && mounted) {
      // Reload diseases if a new one was added
      _loadData();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedGreenhouse == null ||
        _selectedDisease == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final fields = {
        'detected_date': _detectedDate.toIso8601String(),
        'symptoms': _symptomController.text,
        'treatment_note': _treatmentController.text,
        'greenhouse_id': _selectedGreenhouse!.greenhouseId,
        'disease_id': _selectedDisease!.id,
      };

      String? response;
      if (_imageFile != null) {
        response = await _imageService.uploadImage(
          imageFile: _imageFile!,
          endpoint: '/disease-infected',
          fields: fields,
          token: token,
        );
      } else {
        final infected = await _diseaseInfectedService.createDiseaseInfected(
          detectedDate: _detectedDate,
          symptoms: _symptomController.text,
          treatmentNote: _treatmentController.text,
          greenhouseId: _selectedGreenhouse!.greenhouseId,
          diseaseId: _selectedDisease!.id,
        );
        response = infected != null ? 'success' : null;
      }

      if (response == null) {
        throw Exception('Failed to create disease detection record');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disease detection record saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Failed to save disease detection record';
      if (e.toString().contains('Not authenticated')) {
        errorMessage = 'Please log in again to continue';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _submitForm,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Disease Detection',
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
              const Text('Image',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_imageFile != null) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 20),
                          onPressed: () => setState(() => _imageFile = null),
                          tooltip: 'Remove image',
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No image selected',
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 20),
                            label: const Text('Take Photo'),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.photo_library, size: 20),
                            label: const Text('Gallery'),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppDropdown<Greenhouse>(
                value: _selectedGreenhouse,
                items: _greenhouses,
                itemLabel: (gh) => gh.greenhouseId,
                itemValue: (gh) => gh,
                onChanged: (gh) => setState(() => _selectedGreenhouse = gh),
                labelText: 'Greenhouse',
                hintText: 'Select greenhouse',
                isRequired: true,
              ),
              if (_selectedGreenhouse != null) ...[
                const SizedBox(height: 16),
                GreenhouseInfoCard(
                  greenhouse: _selectedGreenhouse!,
                  showBatches: true,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppDropdown<Disease>(
                      value: _selectedDisease,
                      items: _diseases,
                      itemLabel: (d) => '${d.name} (${d.type.name})',
                      itemValue: (d) => d,
                      onChanged: (d) => setState(() => _selectedDisease = d),
                      labelText: 'Disease/Virus',
                      hintText: 'Select disease or virus',
                      isRequired: true,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    child: IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: AppColors.primary,
                      onPressed: _navigateToAddDisease,
                      tooltip: 'Add new disease',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppDatePickerField(
                labelText: 'Detected Date',
                selectedDate: _detectedDate,
                onDateSelected: (date) {
                  if (date != null) {
                    setState(() => _detectedDate = date);
                  }
                },
              ),
              const SizedBox(height: 24),
              AppMultilineTextField(
                controller: _symptomController,
                labelText: 'Symptoms',
                hintText: 'Enter observed symptoms',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter symptoms';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AppMultilineTextField(
                controller: _treatmentController,
                labelText: 'Treatment',
                hintText: 'Enter treatment details',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter treatment details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AppSaveButton(
                onPressed: _submitForm,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
