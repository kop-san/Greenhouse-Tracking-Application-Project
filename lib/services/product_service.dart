import 'dart:developer' as developer;
import 'package:tracking_app/services/api_service.dart';
import 'package:tracking_app/models/product.dart';

class ProductService {
  final ApiService _apiService;

  ProductService(this._apiService);

  // Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _apiService.get('/products');
      final List<dynamic> data = response;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error fetching products: $e', name: 'ProductService');
      rethrow;
    }
  }

  // Get product by ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await _apiService.get('/products/$id');
      return Product.fromJson(response);
    } catch (e) {
      developer.log('Error fetching product: $e', name: 'ProductService');
      rethrow;
    }
  }

  // Create product
  Future<Product> createProduct({
    required String species,
    required int harvestPeriodDays,
  }) async {
    try {
      final response = await _apiService.post(
        '/products',
        {
          'species': species,
          'harvest_period_days': harvestPeriodDays,
        },
      );
      return Product.fromJson(response);
    } catch (e) {
      developer.log('Error creating product: $e', name: 'ProductService');
      rethrow;
    }
  }

  // Update product
  Future<Product> updateProduct({
    required String id,
    required String species,
    required int harvestPeriodDays,
  }) async {
    try {
      final response = await _apiService.put(
        '/products/$id',
        {
          'species': species,
          'harvest_period_days': harvestPeriodDays,
        },
      );
      return Product.fromJson(response);
    } catch (e) {
      developer.log('Error updating product: $e', name: 'ProductService');
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _apiService.delete('/products/$id');
      developer.log('Product deleted successfully', name: 'ProductService');
    } catch (e) {
      developer.log('Error deleting product: $e', name: 'ProductService');
      rethrow;
    }
  }
}
