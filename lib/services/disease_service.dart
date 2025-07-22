import 'dart:developer' as developer;
import 'package:tracking_app/services/api_service.dart';
import 'package:tracking_app/models/disease.dart';

class DiseaseService {
  final ApiService _apiService;
  final String _endpoint = '/disease';

  DiseaseService(this._apiService);

  Future<Disease> createDisease({
    required String diseaseName,
    required DiseaseType diseaseType,
    String? description,
  }) async {
    try {
      developer.log('Creating disease: $diseaseName, type: ${diseaseType.name}',
          name: 'DiseaseService');

      final response = await _apiService.post(
        _endpoint,
        {
          'disease_name': diseaseName,
          'disease_type': diseaseType.name,
          if (description != null) 'description': description,
        },
      );

      final disease = Disease.fromJson(response);
      developer.log('Disease created successfully with ID: ${disease.id}',
          name: 'DiseaseService');
      return disease;
    } catch (e) {
      developer.log('Error creating disease', name: 'DiseaseService', error: e);
      rethrow;
    }
  }

  Future<List<Disease>> getAllDiseases() async {
    try {
      developer.log('Fetching all diseases', name: 'DiseaseService');
      final response = await _apiService.get(_endpoint);
      final List<dynamic> data = response;
      final diseases = data.map((json) => Disease.fromJson(json)).toList();
      developer.log('Successfully fetched ${diseases.length} diseases',
          name: 'DiseaseService');
      return diseases;
    } catch (e) {
      developer.log('Error fetching diseases',
          name: 'DiseaseService', error: e);
      rethrow;
    }
  }

  Future<Disease> getDiseaseById(String id) async {
    try {
      developer.log('Fetching disease with ID: $id', name: 'DiseaseService');
      final response = await _apiService.get('$_endpoint/$id');
      final disease = Disease.fromJson(response);
      developer.log('Successfully fetched disease: ${disease.name}',
          name: 'DiseaseService');
      return disease;
    } catch (e) {
      developer.log('Error fetching disease with ID: $id',
          name: 'DiseaseService', error: e);
      rethrow;
    }
  }

  Future<Disease?> updateDisease(
    String id, {
    required String diseaseName,
    required DiseaseType diseaseType,
    String? description,
    bool removeImage = false,
  }) async {
    try {
      final response = await _apiService.put(
        '$_endpoint/$id',
        {
          'disease_name': diseaseName,
          'disease_type': diseaseType.name,
          if (description != null) 'description': description,
          if (removeImage) 'remove_image': 'true',
        },
      );

      if (response == null) return null;

      return Disease.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDisease(String id) async {
    try {
      developer.log('Deleting disease with ID: $id', name: 'DiseaseService');
      await _apiService.delete('$_endpoint/$id');
      developer.log('Disease deleted successfully', name: 'DiseaseService');
    } catch (e) {
      developer.log('Error deleting disease with ID: $id',
          name: 'DiseaseService', error: e);
      rethrow;
    }
  }
}
