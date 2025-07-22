import 'dart:developer' as developer;
import '/models/harvested.dart';
import 'api_service.dart';

class HarvestedService {
  final ApiService _apiService;
  
  HarvestedService({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

  // Get all harvested records
  Future<List<Harvested>> getAllHarvested() async {
    try {
      final response = await _apiService.get('/harvested');
      if (response is! List) {
        throw ApiException('Expected array response from server');
      }
      return response.map((json) => Harvested.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      developer.log('Error fetching harvested records: $e', name: 'HarvestedService');
      rethrow;
    }
  }

  // Get harvested by ID
  Future<Harvested> getHarvestedById(String id) async {
    try {
      final response = await _apiService.get('/harvested/$id');
      return Harvested.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      developer.log('Error fetching harvested record $id: $e', name: 'HarvestedService');
      rethrow;
    }
  }

  // Create new harvested record
  Future<Harvested> createHarvested({
    required double gradeA,
    required double gradeB,
    required double waste,
    required double totalWeight,
    required HarvestStatus status,
    required String batchId,
    String? note,
  }) async {
    try {
      final response = await _apiService.post(
        '/harvested',
        {
          'grade_A': gradeA,
          'grade_B': gradeB,
          'waste': waste,
          'total_weight': totalWeight,
          'status': status.toString().split('.').last,
          'batch_id': batchId,
          if (note != null) 'note': note,
        },
      );
      return Harvested.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      developer.log('Error creating harvested record: $e', name: 'HarvestedService');
      rethrow;
    }
  }

  // Update harvested record
  Future<Harvested> updateHarvested(
    String id, {
    double? gradeA,
    double? gradeB,
    double? waste,
    double? totalWeight,
    HarvestStatus? status,
    String? note,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (gradeA != null) data['grade_A'] = gradeA;
      if (gradeB != null) data['grade_B'] = gradeB;
      if (waste != null) data['waste'] = waste;
      if (totalWeight != null) data['total_weight'] = totalWeight;
      if (status != null) data['status'] = status.toString().split('.').last;
      if (note != null) data['note'] = note;

      final response = await _apiService.put('/harvested/$id', data);
      return Harvested.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      developer.log('Error updating harvested record $id: $e', name: 'HarvestedService');
      rethrow;
    }
  }

  // Delete harvested record
  Future<void> deleteHarvested(String id) async {
    try {
      await _apiService.delete('/harvested/$id');
    } catch (e) {
      developer.log('Error deleting harvested record $id: $e', name: 'HarvestedService');
      rethrow;
    }
  }
} 