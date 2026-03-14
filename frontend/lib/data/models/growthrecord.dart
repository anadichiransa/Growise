import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthRecord {
  final String id;
  final String childId;
  final String userId;
  final DateTime date;
  final double weight;
  final double height;
  final double? bmi;
  final double? weightForAgeZ;
  final double? heightForAgeZ;
  final String? category;
  final List<String> recommendations;
  final String? notes;
  final DateTime createdAt;
  final bool isSyncedToBackend;
  const GrowthRecord({
    required this.id,
    required this.childId,
    required this.userId,
    required this.date,
    required this.weight,
    required this.height,
    this.bmi,
    this.weightForAgeZ,
    this.heightForAgeZ,
    this.category,
    this.recommendations = const [],
    this.notes,
    required this.createdAt,
    this.isSyncedToBackend = false,
  });
  factory GrowthRecord.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GrowthRecord(
      id: doc.id,
      childId: d['childId'] as String,
      userId: d['userId'] as String,
      date: (d['date'] as Timestamp).toDate(),
      weight: (d['weight'] as num).toDouble(),
      height: (d['height'] as num).toDouble(),
      bmi: d['bmi'] != null ? (d['bmi'] as num).toDouble() : null,
      weightForAgeZ: d['weightForAgeZ'] != null
          ? (d['weightForAgeZ'] as num).toDouble()
          : null,
      heightForAgeZ: d['heightForAgeZ'] != null
          ? (d['heightForAgeZ'] as num).toDouble()
          : null,
      category: d['category'] as String?,
      recommendations: d['recommendations'] != null
          ? List<String>.from(d['recommendations'] as List)
          : [],
      notes: d['notes'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      isSyncedToBackend: d['isSyncedToBackend'] as bool? ?? false,
    );
  }