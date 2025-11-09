class Detection {
  final String label;
  final double score;
  final double x;
  final double y;
  final double w;
  final double h;

  Detection({
    required this.label,
    required this.score,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'score': score,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
    };
  }

  factory Detection.fromMap(Map<String, dynamic> map) {
    return Detection(
      label: map['label'] as String,
      score: (map['score'] as num).toDouble(),
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      w: (map['w'] as num).toDouble(),
      h: (map['h'] as num).toDouble(),
    );
  }
}