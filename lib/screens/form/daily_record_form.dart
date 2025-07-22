import 'package:flutter/material.dart';
import '/constrants/app_colors.dart';
import '/models/daily_check.dart';
import '/models/greenhouse.dart';
import '/services/daily_check_service.dart';
import '/services/greenhouse_service.dart';
import '/services/auth_service.dart';
import '/widgets/app_dropdown.dart';
import '/widgets/app_text_field.dart';
import '/widgets/app_status_button_grid.dart';
import '/widgets/app_save_button.dart';
import '/widgets/greenhouse_info_card.dart';
import 'package:provider/provider.dart';

class DailyRecordForm extends StatefulWidget {
  const DailyRecordForm({super.key});

  @override
  State<DailyRecordForm> createState() => _DailyRecordFormState();
}

class _DailyRecordFormState extends State<DailyRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _dailyCheckService = DailyCheckService();
  final _greenhouseService = GreenhouseService();

  bool _isLoading = true;
  List<Greenhouse> _greenhouses = [];
  String? _selectedGreenhouseId;
  Greenhouse? _selectedGreenhouse;

  // Parameter controllers
  final _ecController = TextEditingController();
  final _phController = TextEditingController();
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();
  final _soilTempController = TextEditingController();
  final _ghTempController = TextEditingController();
  final _soilHumidController = TextEditingController();
  final _ghHumidController = TextEditingController();

  // Status
  CheckStatus? _status;
  final Map<CheckStatus, Color> _statusColors = {
    CheckStatus.Healthy: Colors.green,
    CheckStatus.Virus: Colors.red,
    CheckStatus.Disease: Colors.orange,
    CheckStatus.Rest: Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadGreenhouses();
  }

  Future<void> _loadGreenhouses() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      final greenhouses = await _greenhouseService.getAllGreenhouses();
      if (!mounted) return;
      setState(() {
        _greenhouses = greenhouses;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading greenhouses: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _ecController.dispose();
    _phController.dispose();
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _soilTempController.dispose();
    _ghTempController.dispose();
    _soilHumidController.dispose();
    _ghHumidController.dispose();
    super.dispose();
  }

  void _onGreenhouseChanged(Greenhouse? greenhouse) {
    setState(() {
      _selectedGreenhouse = greenhouse;
      _selectedGreenhouseId = greenhouse?.greenhouseId;
    });
  }

  void _onStatusSelected(CheckStatus status) {
    setState(() {
      _status = status;

      // If Rest status is selected, show dialog to confirm setting all parameters to 0
      if (status == CheckStatus.Rest) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Greenhouse Rest Mode'),
              content: const Text(
                  'When a greenhouse is in rest mode, all parameters will be set to 0. '
                  'Would you like to set all parameters to 0 now?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    _setAllParametersToZero();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _setAllParametersToZero() {
    _ecController.text = '0';
    _phController.text = '0';
    _nController.text = '0';
    _pController.text = '0';
    _kController.text = '0';
    _soilTempController.text = '0';
    _ghTempController.text = '0';
    _soilHumidController.text = '0';
    _ghHumidController.text = '0';
  }

  String? _validateParameter(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Please enter a valid number';
    }

    // Allow 0 values if greenhouse is in rest mode
    if (_status == CheckStatus.Rest) {
      return null;
    }

    // For non-rest status, ensure values are positive
    if (numValue <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedGreenhouse == null ||
        _status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Get current user from AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final dailyCheck = DailyCheck(
        checkDate: DateTime.now(),
        checkStatus: _status!,
        ec: double.parse(_ecController.text),
        ph: double.parse(_phController.text),
        n: double.parse(_nController.text),
        p: double.parse(_pController.text),
        k: double.parse(_kController.text),
        soilTemp: double.parse(_soilTempController.text),
        soilHumid: double.parse(_soilHumidController.text),
        greenhouseTemp: double.parse(_ghTempController.text),
        greenhouseHumid: double.parse(_ghHumidController.text),
        greenhouseId: _selectedGreenhouseId!,
        userId: currentUser.id,
      );

      await _dailyCheckService.createDailyCheck(dailyCheck);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily record saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving daily record: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Record Form',
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
              AppDropdown<Greenhouse>(
                value: _selectedGreenhouse,
                items: _greenhouses,
                itemLabel: (gh) => gh.greenhouseId,
                itemValue: (gh) => gh,
                onChanged: _onGreenhouseChanged,
                labelText: 'Greenhouse',
                hintText: 'Select greenhouse',
                isRequired: true,
              ),
              if (_selectedGreenhouse != null) ...[
                const SizedBox(height: 16),
                GreenhouseInfoCard(greenhouse: _selectedGreenhouse!),
                const SizedBox(height: 24),
                const Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                AppStatusButtonGrid(
                  items: CheckStatus.values,
                  selectedItem: _status,
                  onSelected: _onStatusSelected,
                  getLabel: (status) => status.toString().split('.').last,
                  getColor: (status) => _statusColors[status]!,
                ),
                if (_status == CheckStatus.Rest) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Greenhouse is in rest mode. All parameters can be set to 0.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Parameters',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _ecController,
                  labelText: 'EC',
                  hintText: 'Enter EC value',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => _validateParameter(value, 'EC'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phController,
                  labelText: 'pH',
                  hintText: 'Enter pH value',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => _validateParameter(value, 'pH'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nController,
                  labelText: 'N',
                  hintText: 'Enter N value',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => _validateParameter(value, 'N'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _pController,
                  labelText: 'P',
                  hintText: 'Enter P value',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => _validateParameter(value, 'P'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _kController,
                  labelText: 'K',
                  hintText: 'Enter K value',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => _validateParameter(value, 'K'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _soilTempController,
                  labelText: 'Soil Temperature',
                  hintText: 'Enter soil temperature',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      _validateParameter(value, 'Soil temperature'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _soilHumidController,
                  labelText: 'Soil Humidity',
                  hintText: 'Enter soil humidity',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      _validateParameter(value, 'Soil humidity'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _ghTempController,
                  labelText: 'Greenhouse Temperature',
                  hintText: 'Enter greenhouse temperature',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      _validateParameter(value, 'Greenhouse temperature'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _ghHumidController,
                  labelText: 'Greenhouse Humidity',
                  hintText: 'Enter greenhouse humidity',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      _validateParameter(value, 'Greenhouse humidity'),
                ),
              ],
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
