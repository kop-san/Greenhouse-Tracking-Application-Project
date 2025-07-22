enum HarvestStatus {
  Pending,
  Completed,
}

class Harvested {
  final String harvestedId;
  final double gradeA;
  final double gradeB;
  final double waste;
  final double totalWeight;
  final HarvestStatus status;
  final String batchId;
  final String? note;

  Harvested({
    required this.harvestedId,
    required this.gradeA,
    required this.gradeB,
    required this.waste,
    required this.totalWeight,
    required this.status,
    required this.batchId,
    this.note,
  });

  factory Harvested.fromJson(Map<String, dynamic> json) {
    return Harvested(
      harvestedId: json['harvested_id'] as String,
      gradeA: (json['grade_A'] as num).toDouble(),
      gradeB: (json['grade_B'] as num).toDouble(),
      waste: (json['waste'] as num).toDouble(),
      totalWeight: (json['total_weight'] as num).toDouble(),
      status: HarvestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      batchId: json['batch_id'] as String,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'harvested_id': harvestedId,
      'grade_A': gradeA,
      'grade_B': gradeB,
      'waste': waste,
      'total_weight': totalWeight,
      'status': status.toString().split('.').last,
      'batch_id': batchId,
      if (note != null) 'note': note,
    };
  }

  Harvested copyWith({
    String? harvestedId,
    double? gradeA,
    double? gradeB,
    double? waste,
    double? totalWeight,
    HarvestStatus? status,
    String? batchId,
    String? note,
  }) {
    return Harvested(
      harvestedId: harvestedId ?? this.harvestedId,
      gradeA: gradeA ?? this.gradeA,
      gradeB: gradeB ?? this.gradeB,
      waste: waste ?? this.waste,
      totalWeight: totalWeight ?? this.totalWeight,
      status: status ?? this.status,
      batchId: batchId ?? this.batchId,
      note: note ?? this.note,
    );
  }
} 