class Plant {
  final int? id;
  final String name;
  final String scientificName;
  final String description;
  final String imagePath;
  final String detectedLabel;
  final double confidence;
  final DateTime? createdAt;

  Plant({
    this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imagePath,
    required this.detectedLabel,
    required this.confidence,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'imagePath': imagePath,
      'detectedLabel': detectedLabel,
      'confidence': confidence,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] as int?,
      name: map['name'] as String,
      scientificName: map['scientificName'] as String,
      description: map['description'] as String,
      imagePath: map['imagePath'] as String,
      detectedLabel: map['detectedLabel'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}