import 'package:tracking_app/models/disease.dart';
import 'package:tracking_app/models/greenhouse.dart';

class DiseaseInfected {
  final String diseaseId;
  final DateTime detectedDate;
  final String? symptoms;
  final String? treatmentNote;
  final String greenhouseId;
  final String? imageUrl;
  final Disease? disease;
  final Greenhouse? greenhouse;

  DiseaseInfected({
    required this.diseaseId,
    required this.detectedDate,
    this.symptoms,
    this.treatmentNote,
    required this.greenhouseId,
    this.imageUrl,
    this.disease,
    this.greenhouse,
  });

  factory DiseaseInfected.fromJson(Map<String, dynamic> json) {
    return DiseaseInfected(
      diseaseId: json['disease_id'] as String,
      detectedDate: DateTime.parse(json['detected_date'] as String),
      symptoms: json['symptoms'] as String?,
      treatmentNote: json['treatment_note'] as String?,
      greenhouseId: json['greenhouse_id'] as String,
      imageUrl: json['image_url'] as String?,
      disease: json['disease'] != null ? Disease.fromJson(json['disease'] as Map<String, dynamic>) : null,
      greenhouse: json['greenhouse'] != null ? Greenhouse.fromJson(json['greenhouse'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease_id': diseaseId,
      'detected_date': detectedDate.toIso8601String(),
      if (symptoms != null) 'symptoms': symptoms,
      if (treatmentNote != null) 'treatment_note': treatmentNote,
      'greenhouse_id': greenhouseId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (disease != null) 'disease': disease!.toJson(),
      if (greenhouse != null) 'greenhouse': greenhouse!.toJson(),
    };
  }

  DiseaseInfected copyWith({
    String? diseaseId,
    DateTime? detectedDate,
    String? symptoms,
    String? treatmentNote,
    String? greenhouseId,
    String? imageUrl,
    Disease? disease,
    Greenhouse? greenhouse,
  }) {
    return DiseaseInfected(
      diseaseId: diseaseId ?? this.diseaseId,
      detectedDate: detectedDate ?? this.detectedDate,
      symptoms: symptoms ?? this.symptoms,
      treatmentNote: treatmentNote ?? this.treatmentNote,
      greenhouseId: greenhouseId ?? this.greenhouseId,
      imageUrl: imageUrl ?? this.imageUrl,
      disease: disease ?? this.disease,
      greenhouse: greenhouse ?? this.greenhouse,
    );
  }
} 