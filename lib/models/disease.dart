enum DiseaseType {
  virus,
  disease,
}

class Disease {
  final String id;
  final String name;
  final DiseaseType type;
  final String? imageUrl;
  final String? description;

  Disease({
    required this.id,
    required this.name,
    required this.type,
    this.imageUrl,
    this.description,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['disease_id'],
      name: json['disease_name'],
      type: DiseaseType.values.firstWhere(
        (e) => e.name == json['disease_type'].toString().toLowerCase(),
      ),
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease_id': id,
      'disease_name': name,
      'disease_type': type.name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
    };
  }

  Disease copyWith({
    String? id,
    String? name,
    DiseaseType? type,
    String? imageUrl,
    String? description,
  }) {
    return Disease(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }
} 