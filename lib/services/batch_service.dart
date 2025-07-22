import 'dart:developer' as developer;
import 'package:tracking_app/services/api_service.dart';
import '../models/batch.dart';

class BatchService {
  final ApiService _apiService;
  
  BatchService(this._apiService);

  Future<Map<String, dynamic>> createBatch({
    required DateTime plantedDate,
    required int plantedQuantity,
    required DateTime expectedDate,
    required String productId,
    required String greenhouseId,
    String? harvestedId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
          'planted_date': plantedDate.toIso8601String(),
          'planted_quantity': plantedQuantity,
          'expected_harvest': expectedDate.toIso8601String(),
          'product_id': productId,
          'greenhouse_id': greenhouseId,
      };
      
      if (harvestedId != null) {
        requestBody['harvested_id'] = harvestedId;
      }

      final response = await _apiService.post('/batch', requestBody);
      return response;
    } catch (e) {
      developer.log('Error creating batch: $e', name: 'BatchService');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllBatches() async {
    try {
      final response = await _apiService.get('/batch');
      if (response is! List) {
        throw ApiException('Expected array response from server');
      }
      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      developer.log('Error fetching batches: $e', name: 'BatchService');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBatchById(String id) async {
    try {
      final response = await _apiService.get('/batch/$id');
      return response;
    } catch (e) {
      developer.log('Error fetching batch: $e', name: 'BatchService');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBatch({
    required String batchId,
    required DateTime plantedDate,
    required int plantedQuantity,
    required DateTime expectedDate,
    required String productId,
    required String harvestedId,
    required String greenhouseId,
  }) async {
    try {
      final response = await _apiService.put(
        '/batch/$batchId',
        {
          'planted_date': plantedDate.toIso8601String(),
          'planted_quantity': plantedQuantity,
          'expected_date': expectedDate.toIso8601String(),
          'product_id': productId,
          'harvested_id': harvestedId,
          'greenhouse_id': greenhouseId,
        },
      );
      return response;
    } catch (e) {
      developer.log('Error updating batch: $e', name: 'BatchService');
      rethrow;
    }
  }

  Future<void> deleteBatch(String id) async {
    try {
      await _apiService.delete('/batch/$id');
    } catch (e) {
      developer.log('Error deleting batch: $e', name: 'BatchService');
      rethrow;
    }
  }
}