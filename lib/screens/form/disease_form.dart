import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '/constrants/app_colors.dart';
import '/models/disease.dart';
import '/services/disease_service.dart';
import '/services/api_service.dart';
import '/services/auth_service.dart';
import '/services/image_service.dart';
import '/widgets/app_dropdown.dart';
import '/widgets/app_text_field.dart';
import '/widgets/app_multiline_text_field.dart';
import '/widgets/app_save_button.dart';

class DiseaseForm extends StatefulWidget {
  final Disease? disease;

  const DiseaseForm({
    super.key,
    this.disease,
  });

  @override
  State<DiseaseForm> createState() => _DiseaseFormState();
}

class _DiseaseFormState extends State<DiseaseForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late final _diseaseService = DiseaseService(_apiService);
  late ImageService _imageService;
  bool _isInitialized = false;
  final _diseaseNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;
  String? _error;
  DiseaseType? _selectedDiseaseType;
  bool _shouldRemoveExistingImage = false;

  final List<Map<String, dynamic>> _diseaseTypeOptions = [
    {'label': 'Disease', 'value': DiseaseType.disease},
    {'label': 'Virus', 'value': DiseaseType.virus},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.disease != null) {
      _diseaseNameController.text = widget.disease!.name;
      _descriptionController.text = widget.disease!.description ?? '';
      _selectedDiseaseType = widget.disease!.type;
    }
  }

  @override
  void dispose() {
    _diseaseNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _imageService =
          ImageService(apiService: _apiService, authService: authService);
      _isInitialized = true;
    }
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDiseaseType == null) {
      setState(() => _error = 'Please select a disease type');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final fields = {
        'disease_name': _diseaseNameController.text,
        'disease_type': _selectedDiseaseType!.name,
        'description': _descriptionController.text,
        if (_shouldRemoveExistingImage) 'remove_image': 'true',
      };

      String? response;
      if (_imageFile != null) {
        if (widget.disease != null) {
          response = await _imageService.updateImageWithPut(
            imageFile: _imageFile!,
            endpoint: '/disease/${widget.disease!.id}',
            fields: fields,
            token: token,
          );
        } else {
          response = await _imageService.uploadImage(
            imageFile: _imageFile!,
            endpoint: '/disease',
            fields: fields,
            token: token,
          );
        }
      } else {
        // Create or update disease without image
        if (widget.disease != null) {
          final disease = await _diseaseService.updateDisease(
            widget.disease!.id,
            diseaseName: _diseaseNameController.text,
            diseaseType: _selectedDiseaseType!,
            description: _descriptionController.text,
            removeImage: _shouldRemoveExistingImage,
          );
          response = disease != null ? 'success' : null;
        } else {
          final disease = await _diseaseService.createDisease(
            diseaseName: _diseaseNameController.text,
            diseaseType: _selectedDiseaseType!,
            description: _descriptionController.text,
          );
          response = disease != null ? 'success' : null;
        }
      }

      if (response == null) {
        throw Exception(
            'Failed to ${widget.disease != null ? 'update' : 'create'} disease');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Disease ${widget.disease != null ? 'updated' : 'added'} successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      String errorMessage =
          'Failed to ${widget.disease != null ? 'update' : 'create'} disease';
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
            onPressed: _handleSubmit,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleImageRemoval() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Image'),
          content: const Text('Are you sure you want to remove this image?'),
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
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _imageFile = null;
        if (widget.disease?.imageUrl != null) {
          _shouldRemoveExistingImage = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.disease != null ? 'Edit Disease' : 'Add Disease',
          style: const TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Image',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if ((_imageFile != null ||
                          widget.disease?.imageUrl != null) &&
                      !_shouldRemoveExistingImage) ...[
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _imageFile != null
                                ? Image.file(
                                    _imageFile!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    widget.disease!.imageUrl!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: AppColors.lightPrimary
                                          .withValues(alpha: 0.1),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 64,
                                        color: AppColors.lightPrimary,
                                      ),
                                    ),
                                  ),
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
                            onPressed: _handleImageRemoval,
                            tooltip: 'Remove image',
                          ),
                        ),
                      ],
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
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _diseaseNameController,
                    labelText: 'Disease Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter disease name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  AppDropdown<DiseaseType>(
                    value: _selectedDiseaseType,
                    items: _diseaseTypeOptions
                        .map((type) => type['value'] as DiseaseType)
                        .toList(),
                    itemLabel: (type) => _diseaseTypeOptions
                        .firstWhere((opt) => opt['value'] == type)['label']
                        .toString(),
                    itemValue: (type) => type,
                    onChanged: (type) =>
                        setState(() => _selectedDiseaseType = type),
                    labelText: 'Disease Type',
                    hintText: 'Select disease type',
                    isRequired: true,
                  ),
                  const SizedBox(height: 24),
                  AppMultilineTextField(
                    controller: _descriptionController,
                    labelText: 'Description',
                    hintText: 'Enter disease description',
                  ),
                  const SizedBox(height: 24),
                  AppSaveButton(
                    onPressed: _handleSubmit,
                    isLoading: _isLoading,
                    text: widget.disease != null
                        ? 'Update Disease'
                        : 'Add Disease',
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
