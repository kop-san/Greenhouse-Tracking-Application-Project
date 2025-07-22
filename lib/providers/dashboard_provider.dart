import 'package:flutter/material.dart';
import 'package:tracking_app/models/batch.dart';
import 'package:tracking_app/models/harvested.dart';
import 'package:tracking_app/models/product.dart';
import 'package:tracking_app/services/batch_service.dart';
import 'package:tracking_app/services/harvested_service.dart';
import 'package:tracking_app/services/product_service.dart';

class DashboardProvider extends ChangeNotifier {
  final BatchService _batchService;
  final HarvestedService _harvestedService;
  final ProductService _productService;

  List<Batch> _batches = [];
  List<Harvested> _harvested = [];
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedProductType;

  // Getters
  List<Batch> get batches => _batches;
  List<Harvested> get harvested => _harvested;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedProductType => _selectedProductType;
  List<String> get productTypes => ['All', ..._products.map((p) => p.species).toSet().toList()];

  DashboardProvider(this._batchService, this._harvestedService, this._productService);

  Future<void> loadData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final batchesJson = await _batchService.getAllBatches();
      _batches = batchesJson.map((json) => Batch.fromJson(json)).toList();

      _harvested = await _harvestedService.getAllHarvested();
      _products = await _productService.getAllProducts();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedProductType(String? productType) {
    _selectedProductType = productType;
    notifyListeners();
  }

  Map<String, dynamic> getDashboardData() {
    List<Batch> filteredBatches = _batches;
    List<Harvested> filteredHarvested = _harvested;

    if (_selectedProductType != null && _selectedProductType != 'All') {
      final productIds = _products
          .where((p) => p.species == _selectedProductType)
          .map((p) => p.productId)
          .toSet();

      filteredBatches = _batches.where((b) => productIds.contains(b.productId)).toList();

      final batchIds = filteredBatches.map((b) => b.batchId).toSet();
      filteredHarvested = _harvested.where((h) => batchIds.contains(h.batchId)).toList();
    }

    final plantedQuantity = filteredBatches.fold<double>(
      0, (sum, batch) => sum + batch.plantedQuantity);

    final productQuantity = filteredHarvested.fold<double>(
      0, (sum, harvest) => sum + harvest.totalWeight);

    final damagedQuantity = filteredHarvested.fold<double>(
      0, (sum, harvest) => sum + harvest.waste);

    final gradeAQuantity = filteredHarvested.fold<double>(
      0, (sum, harvest) => sum + harvest.gradeA);

    final gradeBQuantity = filteredHarvested.fold<double>(
      0, (sum, harvest) => sum + harvest.gradeB);

    final goodQuality = gradeAQuantity + gradeBQuantity;
    final badQuality = damagedQuantity;

    return {
      'plantedQuantity': '${plantedQuantity.toStringAsFixed(2)} kg',
      'productQuantity': '${productQuantity.toStringAsFixed(2)} kg',
      'damagedQuantity': '${damagedQuantity.toStringAsFixed(2)} kg',
      'goodQuality': '${goodQuality.toStringAsFixed(2)} kg',
      'badQuality': '${badQuality.toStringAsFixed(2)} kg',
      'gradeA': '${gradeAQuantity.toStringAsFixed(2)} kg',
      'gradeB': '${gradeBQuantity.toStringAsFixed(2)} kg',
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 