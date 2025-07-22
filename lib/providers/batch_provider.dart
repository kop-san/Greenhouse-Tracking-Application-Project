import 'package:flutter/material.dart';
import 'package:tracking_app/models/batch.dart';
import 'package:tracking_app/models/product.dart';
import 'package:tracking_app/services/batch_service.dart';
import 'package:tracking_app/services/product_service.dart';

class BatchProvider extends ChangeNotifier {
  final BatchService _batchService;
  final ProductService _productService;

  List<Batch> _batches = [];
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Batch> get batches => _batches;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BatchProvider(this._batchService, this._productService);

  Future<void> loadBatches() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final batchesJson = await _batchService.getAllBatches();
      _batches = batchesJson.map((json) => Batch.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _productService.getAllProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Batch?> getBatchById(String id) async {
    try {
      final cached = _batches.firstWhere(
        (b) => b.batchId == id,
        orElse: () => null as Batch,
      );

      if (cached != null) return cached;

      final batchJson = await _batchService.getBatchById(id);
      final batch = Batch.fromJson(batchJson);
      
      final index = _batches.indexWhere((b) => b.batchId == id);
      if (index >= 0) {
        _batches[index] = batch;
      } else {
        _batches.add(batch);
      }
      
      notifyListeners();
      return batch;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createBatch({
    required DateTime plantedDate,
    required DateTime expectedDate,
    required int plantedQuantity,
    required String greenhouseId,
    required String productId,
    required String harvestedId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final batchJson = await _batchService.createBatch(
        plantedDate: plantedDate,
        expectedDate: expectedDate,
        plantedQuantity: plantedQuantity,
        greenhouseId: greenhouseId,
        productId: productId,
        harvestedId: harvestedId,
      );

      final batch = Batch.fromJson(batchJson);
      _batches.add(batch);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBatch({
    required String batchId,
    required DateTime plantedDate,
    required DateTime expectedDate,
    required int plantedQuantity,
    required String greenhouseId,
    required String productId,
    required String harvestedId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final batchJson = await _batchService.updateBatch(
        batchId: batchId,
        plantedDate: plantedDate,
        expectedDate: expectedDate,
        plantedQuantity: plantedQuantity,
        greenhouseId: greenhouseId,
        productId: productId,
        harvestedId: harvestedId,
      );

      final batch = Batch.fromJson(batchJson);
      final index = _batches.indexWhere((b) => b.batchId == batchId);
      if (index >= 0) {
        _batches[index] = batch;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBatch(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _batchService.deleteBatch(id);
      _batches.removeWhere((b) => b.batchId == id);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 