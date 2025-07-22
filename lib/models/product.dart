import 'package:tracking_app/models/batch.dart';

class Product {
  final String productId;
  final String species;
  final int harvestPeriodDays;
  final List<Batch>? batches;

  Product({
    required this.productId,
    required this.species,
    required this.harvestPeriodDays,
    this.batches,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      species: json['species'],
      harvestPeriodDays: json['harvest_period_days'] ?? 90,
      batches: json['batch'] != null
          ? [Batch.fromJson(json['batch'] as Map<String, dynamic>)]
          : json['batches'] != null
              ? (json['batches'] as List)
                  .map((b) => Batch.fromJson(b as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'species': species,
      'harvest_period_days': harvestPeriodDays,
      if (batches != null) 'batches': batches!.map((b) => b.toJson()).toList(),
    };
  }

  Product copyWith({
    String? productId,
    String? species,
    int? harvestPeriodDays,
    List<Batch>? batches,
  }) {
    return Product(
      productId: productId ?? this.productId,
      species: species ?? this.species,
      harvestPeriodDays: harvestPeriodDays ?? this.harvestPeriodDays,
      batches: batches ?? this.batches,
    );
  }
}
