import 'dart:developer' as developer;
import '../models/daily_check.dart';
import 'api_service.dart';

class DailyCheckService {
  final ApiService _apiService;
  
  DailyCheckService({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

  // Get all daily checks
  Future<List<DailyCheck>> getAllDailyChecks() async {
    try {
      final response = await _apiService.get('/dailycheck');
      if (response is! List) {
        throw Exception('Expected array response from server');
      }
      return response.map((json) => DailyCheck.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error fetching daily checks: $e', name: 'DailyCheckService');
      rethrow;
    }
  }

  // Get daily check by ID
  Future<DailyCheck> getDailyCheckById(int id) async {
    try {
      final response = await _apiService.get('/dailycheck/$id');
      return DailyCheck.fromJson(response);
    } catch (e) {
      developer.log('Error fetching daily check: $e', name: 'DailyCheckService');
      rethrow;
    }
  }

  // Create daily check
  Future<DailyCheck> createDailyCheck(DailyCheck dailyCheck) async {
    try {
      final response = await _apiService.post(
        '/dailycheck',
        dailyCheck.toJson(),
      );
      return DailyCheck.fromJson(response);
    } catch (e) {
      developer.log('Error creating daily check: $e', name: 'DailyCheckService');
      rethrow;
    }
  }

  // Update daily check
  Future<DailyCheck> updateDailyCheck(int id, DailyCheck dailyCheck) async {
    try {
      final response = await _apiService.put(
        '/dailycheck/$id',
        dailyCheck.toJson(),
      );
      return DailyCheck.fromJson(response);
    } catch (e) {
      developer.log('Error updating daily check: $e', name: 'DailyCheckService');
      rethrow;
    }
  }

  // Delete daily check
  Future<void> deleteDailyCheck(int id) async {
    try {
      await _apiService.delete('/dailycheck/$id');
    } catch (e) {
      developer.log('Error deleting daily check: $e', name: 'DailyCheckService');
      rethrow;
    }
  }
} 