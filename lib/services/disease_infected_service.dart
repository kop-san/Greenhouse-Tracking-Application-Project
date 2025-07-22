import 'dart:developer' as developer;
import 'package:tracking_app/services/api_service.dart';
import 'package:tracking_app/models/disease_infected.dart';

class DiseaseInfectedService {
  final ApiService _apiService;
  final String _endpoint = '/disease-infected';

  DiseaseInfectedService(this._apiService);

  Future<DiseaseInfected> createDiseaseInfected({
    required String diseaseId,
    required DateTime detectedDate,
    String? symptoms,
    String? treatmentNote,
    required String greenhouseId,
    String? imageUrl,
  }) async {
    try {
      developer.log(
        'Creating disease infected record for disease: $diseaseId, greenhouse: $greenhouseId',
        name: 'DiseaseInfectedService'
      );

      final response = await _apiService.post(
        _endpoint,
        {
          'disease_id': diseaseId,
          'detected_date': detectedDate.toIso8601String(),
          if (symptoms != null) 'symptoms': symptoms,
          if (treatmentNote != null) 'treatment_note': treatmentNote,
          'greenhouse_id': greenhouseId,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );

      final record = DiseaseInfected.fromJson(response);
      developer.log(
        'Disease infected record created successfully with ID: ${record.diseaseId}',
        name: 'DiseaseInfectedService'
      );
      return record;
    } catch (e) {
      developer.log(
        'Error creating disease infected record',
        name: 'DiseaseInfectedService',
        error: e
      );
      rethrow;
    }
  }

  Future<List<DiseaseInfected>> getAllDiseaseInfected() async {
    try {
      developer.log('Fetching all disease infected records', name: 'DiseaseInfectedService');
      final response = await _apiService.get(_endpoint);
      final List<dynamic> data = response;
      final records = data.map((json) => DiseaseInfected.fromJson(json)).toList();
      developer.log(
        'Successfully fetched ${records.length} disease infected records',
        name: 'DiseaseInfectedService'
      );
      return records;
    } catch (e) {
      developer.log(
        'Error fetching disease infected records',
        name: 'DiseaseInfectedService',
        error: e
      );
      rethrow;
    }
  }

  Future<DiseaseInfected> getDiseaseInfectedById(String id) async {
    try {
      developer.log('Fetching disease infected record with ID: $id', name: 'DiseaseInfectedService');
      final response = await _apiService.get('$_endpoint/$id');
      final record = DiseaseInfected.fromJson(response);
      developer.log(
        'Successfully fetched disease infected record for disease: ${record.diseaseId}',
        name: 'DiseaseInfectedService'
      );
      return record;
    } catch (e) {
      developer.log(
        'Error fetching disease infected record with ID: $id',
        name: 'DiseaseInfectedService',
        error: e
      );
      rethrow;
    }
  }

  Future<DiseaseInfected> updateDiseaseInfected({
    required String id,
    required DateTime detectedDate,
    String? symptoms,
    String? treatmentNote,
    required String greenhouseId,
    String? imageUrl,
  }) async {
    try {
      developer.log(
        'Updating disease infected record with ID: $id',
        name: 'DiseaseInfectedService'
      );

      final response = await _apiService.put(
        '$_endpoint/$id',
        {
          'detected_date': detectedDate.toIso8601String(),
          if (symptoms != null) 'symptoms': symptoms,
          if (treatmentNote != null) 'treatment_note': treatmentNote,
          'greenhouse_id': greenhouseId,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );

      final record = DiseaseInfected.fromJson(response);
      developer.log(
        'Disease infected record updated successfully',
        name: 'DiseaseInfectedService'
      );
      return record;
    } catch (e) {
      developer.log(
        'Error updating disease infected record with ID: $id',
        name: 'DiseaseInfectedService',
        error: e
      );
      rethrow;
    }
  }

  Future<void> deleteDiseaseInfected(String id) async {
    try {
      developer.log('Deleting disease infected record with ID: $id', name: 'DiseaseInfectedService');
      await _apiService.delete('$_endpoint/$id');
      developer.log(
        'Disease infected record deleted successfully',
        name: 'DiseaseInfectedService'
      );
    } catch (e) {
      developer.log(
        'Error deleting disease infected record with ID: $id',
        name: 'DiseaseInfectedService',
        error: e
      );
      rethrow;
    }
  }
} 