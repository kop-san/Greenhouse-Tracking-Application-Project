import 'package:flutter/material.dart';
import '/constrants/app_colors.dart';
import 'package:intl/intl.dart';
import '/widgets/app_dropdown.dart';
import '/widgets/app_date_picker_field.dart';
import '/widgets/app_text_field.dart';
import '/widgets/app_save_button.dart';
import '/services/batch_service.dart';
import '/services/product_service.dart';
import '/services/greenhouse_service.dart';
import '/services/api_service.dart' hide ConnectionException;
import '/models/greenhouse.dart';
import '/models/product.dart';
import '/exceptions/connection_exception.dart';

class BatchesForm extends StatefulWidget {
  const BatchesForm({super.key});

  @override
  State<BatchesForm> createState() => _BatchesFormState();
}

class _BatchesFormState extends State<BatchesForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final _batchService = BatchService(ApiService());
  final _productService = ProductService(ApiService());
  final _greenhouseService = GreenhouseService();

  DateTime? _plantDate;
  Product? _selectedProduct;
  Greenhouse? _selectedGreenhouse;
  DateTime? _expectedHarvest;

  bool _isLoading = true;
  List<Greenhouse> _greenhouses = [];
  List<Product> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final greenhouses = await _greenhouseService.getAllGreenhouses();
      final products = await _productService.getAllProducts();

      if (!mounted) return;
      setState(() {
        _greenhouses = greenhouses;
        _availableProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _onGreenhouseChanged(Greenhouse? greenhouse) {
    setState(() {
      _selectedGreenhouse = greenhouse;
    });
  }

  void _onProductChanged(Product? product) {
    setState(() {
      _selectedProduct = product;
      // Recalculate expected harvest if plant date is already selected
      if (_plantDate != null && product != null) {
        _expectedHarvest =
            _plantDate!.add(Duration(days: product.harvestPeriodDays));
      }
    });
  }

  void _onPlantDateChanged(DateTime? date) {
    setState(() {
      _plantDate = date;
      // Set expected harvest date to product-specific period after plant date
      if (date != null && _selectedProduct != null) {
        _expectedHarvest =
            date.add(Duration(days: _selectedProduct!.harvestPeriodDays));
      } else {
        _expectedHarvest = null;
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _plantDate == null ||
        _expectedHarvest == null ||
        _selectedProduct == null ||
        _selectedGreenhouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _batchService.createBatch(
        plantedDate: _plantDate!,
        plantedQuantity: int.parse(_quantityController.text),
        expectedDate: _expectedHarvest!,
        productId: _selectedProduct!.productId,
        greenhouseId: _selectedGreenhouse!.greenhouseId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch created successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error creating batch';

        if (e is ConnectionException) {
          errorMessage = e.message;
        } else if (e.toString().contains('400')) {
          errorMessage = 'Invalid data provided. Please check all fields.';
        } else if (e.toString().contains('404')) {
          errorMessage =
              'Product or greenhouse not found. Please refresh and try again.';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage = 'An unexpected error occurred. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
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
          'Batches Form',
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
              const SizedBox(height: 16),
              AppDropdown<Product>(
                value: _selectedProduct,
                items: _availableProducts,
                itemLabel: (product) =>
                    '${product.productId} - ${product.species}',
                itemValue: (product) => product,
                onChanged: _onProductChanged,
                labelText: 'Product',
                hintText: _availableProducts.isEmpty
                    ? 'No available products'
                    : 'Select product',
                isRequired: true,
              ),
              if (_selectedProduct != null) ...[
                const SizedBox(height: 8),
                Text(
                    'Harvest Period: ${_selectedProduct!.harvestPeriodDays} days',
                    style: TextStyle(color: Colors.grey)),
              ],
              if (_availableProducts.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Please create a product first using the Product Form',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 16),
              AppDatePickerField(
                selectedDate: _plantDate,
                labelText: 'Plant Date',
                hintText: 'Pick plant date',
                onDateSelected: _onPlantDateChanged,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _quantityController,
                labelText: 'Quantity (Kg)',
                hintText: 'Enter quantity',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Quantity must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Expected Harvest',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  _expectedHarvest != null
                      ? DateFormat('yyyy-MM-dd').format(_expectedHarvest!)
                      : '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
