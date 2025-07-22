import 'package:flutter/material.dart';
import '/constrants/app_colors.dart';

class BatchInfo {
  final String batchId;
  final DateTime plantedDate;
  final String productId;
  final String productName;

  BatchInfo({
    required this.batchId,
    required this.plantedDate,
    required this.productId,
    required this.productName,
  });

  factory BatchInfo.fromJson(Map<String, dynamic> json) {
    return BatchInfo(
      batchId: json['batch_id'],
      plantedDate: DateTime.parse(json['planted_date']),
      productId: json['product_id'],
      productName: json['product']['species'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'planted_date': plantedDate.toIso8601String(),
      'product_id': productId,
      'product': {'species': productName},
    };
  }
}

enum GreenhouseType { Tunel, Sawtooth, Umbrella }

class Greenhouse {
  final String greenhouseId;
  final GreenhouseType type;
  final double width;
  final double height;
  final double length;
  final List<dynamic>? products;
  final Map<String, dynamic>? lastCheck;
  final BatchInfo? activeBatch;

  Greenhouse({
    required this.greenhouseId,
    required this.type,
    required this.width,
    required this.height,
    required this.length,
    this.products,
    this.lastCheck,
    this.activeBatch,
  });

  factory Greenhouse.fromJson(Map<String, dynamic> json) {
    final dailyChecks = json['daily_check'] as List?;
    final latestCheck =
        dailyChecks?.isNotEmpty == true ? dailyChecks![0] : null;

    final activeBatchJson = json['active_batch'] as Map<String, dynamic>?;
    final activeBatch =
        activeBatchJson != null ? BatchInfo.fromJson(activeBatchJson) : null;

    return Greenhouse(
      greenhouseId: json['greenhouse_id'],
      type: _parseGreenhouseType(json['greenhouse_type']),
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      length: json['length'].toDouble(),
      products: json['products'],
      lastCheck: latestCheck,
      activeBatch: activeBatch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greenhouse_id': greenhouseId,
      'greenhouse_type': type.toString().split('.').last,
      'width': width,
      'height': height,
      'length': length,
      'active_batch': activeBatch?.toJson(),
    };
  }

  static GreenhouseType _parseGreenhouseType(String type) {
    switch (type.toLowerCase()) {
      case 'tunel':
        return GreenhouseType.Tunel;
      case 'sawtooth':
        return GreenhouseType.Sawtooth;
      case 'umbrella':
        return GreenhouseType.Umbrella;
      default:
        throw ArgumentError('Invalid greenhouse type: $type');
    }
  }

  String get statusText {
    if (lastCheck == null) {
      return 'NO DATA';
    }

    final status = lastCheck!['check_status'] as String;
    switch (status) {
      case 'Healthy':
        return 'HEALTHY';
      case 'Disease':
        return 'DISEASE';
      case 'Virus':
        return 'VIRUS';
      case 'Rest':
        return 'REST';
      default:
        return 'UNKNOWN';
    }
  }

  Color get statusColor {
    if (lastCheck == null) {
      return AppColors.inactive;
    }

    final status = lastCheck!['check_status'] as String;
    switch (status) {
      case 'Healthy':
        return AppColors.success;
      case 'Disease':
        return AppColors.mild;
      case 'Virus':
        return AppColors.alert;
      case 'Rest':
        return AppColors.inactive;
      default:
        return AppColors.inactive;
    }
  }

  double get area => width * length;
  double get volume => width * length * height;

  Greenhouse copyWith({
    String? greenhouseId,
    GreenhouseType? type,
    double? width,
    double? height,
    double? length,
    List<dynamic>? products,
    Map<String, dynamic>? lastCheck,
    BatchInfo? activeBatch,
  }) {
    return Greenhouse(
      greenhouseId: greenhouseId ?? this.greenhouseId,
      type: type ?? this.type,
      width: width ?? this.width,
      height: height ?? this.height,
      length: length ?? this.length,
      products: products ?? this.products,
      lastCheck: lastCheck ?? this.lastCheck,
      activeBatch: activeBatch ?? this.activeBatch,
    );
  }

  @override
  String toString() {
    return 'Greenhouse(greenhouseId: $greenhouseId, type: $type, size: ${width}x${height}x$length)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Greenhouse && other.greenhouseId == greenhouseId;
  }

  @override
  int get hashCode => greenhouseId.hashCode;
}
