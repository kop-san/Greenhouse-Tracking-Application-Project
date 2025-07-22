import 'package:tracking_app/models/product.dart';
import 'package:tracking_app/models/harvested.dart';

class GreenhouseInfo {
  final String greenhouseId;
  final String type;
  final double width;
  final double height;
  final double length;

  GreenhouseInfo({
    required this.greenhouseId,
    required this.type,
    required this.width,
    required this.height,
    required this.length,
  });

  factory GreenhouseInfo.fromJson(Map<String, dynamic> json) {
    return GreenhouseInfo(
      greenhouseId: json['greenhouse_id'],
      type: json['greenhouse_type'],
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      length: json['length'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greenhouse_id': greenhouseId,
      'greenhouse_type': type,
      'width': width,
      'height': height,
      'length': length,
    };
  }
}

class Batch {
  final String batchId;
  final DateTime plantedDate;
  final DateTime expectedHarvest;
  final int plantedQuantity;
  final String greenhouseId;
  final String productId;
  final GreenhouseInfo? greenhouse;
  final Product? product;
  final Harvested? harvested;

  Batch({
    required this.batchId,
    required this.plantedDate,
    required this.expectedHarvest,
    required this.plantedQuantity,
    required this.greenhouseId,
    required this.productId,
    this.greenhouse,
    this.product,
    this.harvested,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      batchId: json['batch_id'] as String,
      plantedDate: DateTime.parse(json['planted_date'] as String),
      expectedHarvest: DateTime.parse(json['expected_harvest'] as String),
      plantedQuantity: json['planted_quantity'] as int,
      greenhouseId: json['greenhouse_id'] as String,
      productId: json['product_id'] as String,
      greenhouse: json['greenhouse'] != null
          ? GreenhouseInfo.fromJson(json['greenhouse'] as Map<String, dynamic>)
          : null,
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      harvested: json['harvested'] != null
          ? Harvested.fromJson(json['harvested'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'planted_date': plantedDate.toIso8601String(),
      'expected_harvest': expectedHarvest.toIso8601String(),
      'planted_quantity': plantedQuantity,
      'greenhouse_id': greenhouseId,
      'product_id': productId,
      if (greenhouse != null) 'greenhouse': greenhouse!.toJson(),
      if (product != null) 'product': product!.toJson(),
      if (harvested != null) 'harvested': harvested!.toJson(),
    };
  }

  Batch copyWith({
    String? batchId,
    DateTime? plantedDate,
    DateTime? expectedHarvest,
    int? plantedQuantity,
    String? greenhouseId,
    String? productId,
    GreenhouseInfo? greenhouse,
    Product? product,
    Harvested? harvested,
  }) {
    return Batch(
      batchId: batchId ?? this.batchId,
      plantedDate: plantedDate ?? this.plantedDate,
      expectedHarvest: expectedHarvest ?? this.expectedHarvest,
      plantedQuantity: plantedQuantity ?? this.plantedQuantity,
      greenhouseId: greenhouseId ?? this.greenhouseId,
      productId: productId ?? this.productId,
      greenhouse: greenhouse ?? this.greenhouse,
      product: product ?? this.product,
      harvested: harvested ?? this.harvested,
    );
  }
}
