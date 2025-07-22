import 'package:flutter/material.dart';
import '/constrants/app_colors.dart';
import '/widgets/app_text_field.dart';
import '/widgets/app_save_button.dart';
import '/widgets/product_list_item.dart';
import '/services/product_service.dart';
import '/services/api_service.dart';
import '/models/product.dart';

class ProductInfoForm extends StatefulWidget {
  final Product? productToEdit;

  const ProductInfoForm({
    super.key,
    this.productToEdit,
  });

  @override
  State<ProductInfoForm> createState() => _ProductInfoFormState();
}

class _ProductInfoFormState extends State<ProductInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _speciesController = TextEditingController();
  final _harvestPeriodController = TextEditingController();
  late final _productService = ProductService(ApiService());

  bool _isLoading = false;
  List<Product> _products = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _speciesController.text = widget.productToEdit!.species;
      _harvestPeriodController.text =
          widget.productToEdit!.harvestPeriodDays.toString();
    }
    _loadProducts();
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _harvestPeriodController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _productService.getAllProducts();

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(Product product, {bool isEdit = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                isEdit ? 'Product Updated' : 'Product Created',
                style: const TextStyle(
                  color: AppColors.darkPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product ID:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.productId,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Species:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.species,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.darkPrimary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                if (!isEdit) {
                  Navigator.of(context).pop(true); // Return to previous screen
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = widget.productToEdit != null
          ? await _productService.updateProduct(
              id: widget.productToEdit!.productId,
              species: _speciesController.text.trim(),
              harvestPeriodDays:
                  int.parse(_harvestPeriodController.text.trim()),
            )
          : await _productService.createProduct(
              species: _speciesController.text.trim(),
              harvestPeriodDays:
                  int.parse(_harvestPeriodController.text.trim()),
            );

      if (mounted) {
        _showSuccessDialog(product, isEdit: widget.productToEdit != null);
        await _loadProducts(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error ${widget.productToEdit != null ? 'updating' : 'creating'} product: $e')),
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

  void _editProduct(Product product) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ProductInfoForm(productToEdit: product),
      ),
    )
        .then((value) {
      if (value == true) {
        _loadProducts();
      }
    });
  }

  Future<void> _deleteProduct(Product product) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _productService.deleteProduct(product.productId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadProducts(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
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
        title: Text(
          widget.productToEdit != null ? 'Edit Product' : 'Product Information',
          style: const TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _speciesController,
                    labelText: 'Species Name',
                    hintText: 'Enter species name',
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Species name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _harvestPeriodController,
                    labelText: 'Harvest Period (days)',
                    hintText: 'Enter harvest period in days',
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Harvest period is required';
                      }
                      final intValue = int.tryParse(value.trim());
                      if (intValue == null || intValue <= 0) {
                        return 'Enter a valid number of days';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  AppSaveButton(
                    text: _isLoading
                        ? (widget.productToEdit != null
                            ? 'Updating...'
                            : 'Creating...')
                        : (widget.productToEdit != null ? 'Update' : 'Save'),
                    onPressed: _isLoading ? null : _submitForm,
                  ),
                ],
              ),
            ),
            if (widget.productToEdit == null) ...[
              const SizedBox(height: 32),
              const Text(
                'Existing Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                )
              else if (_products.isEmpty)
                const Text(
                  'No products added yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ProductListItem(
                      product: product,
                      onEdit: () => _editProduct(product),
                      onDelete: () => _deleteProduct(product),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
