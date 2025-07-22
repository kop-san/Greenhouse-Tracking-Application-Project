import 'dart:developer' as developer;
import '../models/greenhouse.dart';
import 'api_service.dart';

class GreenhouseService {
  final ApiService _apiService;
  
  GreenhouseService({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

  // Get all greenhouses
  Future<List<Greenhouse>> getAllGreenhouses() async {
    try {
      final response = await _apiService.get('/greenhouses');
      if (response is! List) {
        throw ApiException('Expected array response from server');
      }
      return response.map((json) => Greenhouse.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error fetching greenhouses: $e', name: 'GreenhouseService');
      rethrow;
    }
  }

  // Get greenhouse by ID
  Future<Greenhouse> getGreenhouseById(String id) async {
    try {
      final response = await _apiService.get('/greenhouses/$id');
      return Greenhouse.fromJson(response);
    } catch (e) {
      developer.log('Error fetching greenhouse $id: $e', name: 'GreenhouseService');
      rethrow;
    }
  }

  // Create new greenhouse
  Future<Greenhouse> createGreenhouse(Greenhouse greenhouse) async {
    try {
      final response = await _apiService.post(
        '/greenhouses',
        greenhouse.toJson(),
      );
      return Greenhouse.fromJson(response);
    } catch (e) {
      developer.log('Error creating greenhouse: $e', name: 'GreenhouseService');
      rethrow;
    }
  }

  // Update greenhouse
  Future<Greenhouse> updateGreenhouse(String id, Greenhouse greenhouse) async {
    try {
      final response = await _apiService.put(
        '/greenhouses/$id',
        greenhouse.toJson(),
      );
      return Greenhouse.fromJson(response);
    } catch (e) {
      developer.log('Error updating greenhouse $id: $e', name: 'GreenhouseService');
      rethrow;
    }
  }

  // Delete greenhouse
  Future<void> deleteGreenhouse(String id) async {
    try {
      await _apiService.delete('/greenhouses/$id');
    } catch (e) {
      developer.log('Error deleting greenhouse $id: $e', name: 'GreenhouseService');
      rethrow;
    }
  }
}