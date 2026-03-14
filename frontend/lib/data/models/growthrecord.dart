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