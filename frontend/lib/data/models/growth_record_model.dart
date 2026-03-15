class GrowthRecord {
  final String id;
  final String childId;
  final DateTime date;
  final double weight;
  final double height;
  final double? bmi;
  final double? weightForAgeZ;
  final double? heightForAgeZ;
  final String? category;
  final String? notes;
  final String? measuredAt;
  final DateTime createdAt;
  final String? summary;
  final List<String>? recommendations;

  GrowthRecord({
    required this.id,
    required this.childId,
    required this.date,
    required this.weight,
    required this.height,
    this.bmi,
    this.weightForAgeZ,
    this.heightForAgeZ,
    this.category,
    this.notes,
    this.measuredAt,
    required this.createdAt,
    this.summary,
    this.recommendations,
  });

  static double calculateBMI(double weight, double height) {
    final hm = height / 100;
    return weight / (hm * hm);
  }

  /// Create from backend JSON response
  factory GrowthRecord.fromJson(Map<String, dynamic> json) {
    return GrowthRecord(
      id:             json['id'] ?? '',
      childId:        json['child_id'] ?? '',
      date:           DateTime.parse(json['date']),
      weight:         (json['weight'] as num).toDouble(),
      height:         (json['height'] as num).toDouble(),
      bmi:            json['bmi'] != null
                        ? (json['bmi'] as num).toDouble() : null,
      weightForAgeZ:  json['weight_for_age_z'] != null
                        ? (json['weight_for_age_z'] as num).toDouble() : null,
      heightForAgeZ:  json['height_for_age_z'] != null
                        ? (json['height_for_age_z'] as num).toDouble() : null,
      category:       json['category'],
      notes:          json['notes'],
      measuredAt:     json['measured_at'],
      createdAt:      DateTime.parse(json['created_at']),
      summary:        json['summary'],
      recommendations: json['recommendations'] != null
                        ? List<String>.from(json['recommendations']) : null,
    );
  }
}