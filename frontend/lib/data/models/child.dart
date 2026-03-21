import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a child's profile in the Growise app

class Child {

  final String id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final String parentId;
  final DateTime createdAt;
  final bool isSyncedToBackend;


  Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.parentId,
    required this.createdAt,
    this.isSyncedToBackend = false,  // Default: not synced
  });

  /// Convert Child object to Map for Firestore
  /// 
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),  // Convert DateTime to Timestamp
      'gender': gender,
      'parentId': parentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isSyncedToBackend': isSyncedToBackend,
    };
  }

  /// Create Child object from Firestore data 
  /// When we read from Firestore, we get a Map of data.
  /// This method converts that Map back into a Child object.

  factory Child.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Child(
      id: doc.id,  // Document ID from Firestore
      name: data['name'] ?? '',  // ?? provides default if null
      birthDate: (data['birthDate'] as Timestamp).toDate(),  // Convert Timestamp to DateTime
      gender: data['gender'] ?? 'Boy',
      parentId: data['parentId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isSyncedToBackend: data['isSyncedToBackend'] ?? false,
    );
  }

  /// Convert Child object to JSON for backend API
  /// Our FastAPI backend expects JSON format (different from Firestore).
  /// This method creates a Map that can be converted to JSON.

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate.toIso8601String(),  // ISO 8601 format for API
      'gender': gender.toLowerCase(),  // Backend expects lowercase
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Calculate child's age in months
  /// Used for growth charts and development milestones. 
  /// Returns: Number of months since birth
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12;
    months += now.month - birthDate.month;
    return months;
  }

  /// Calculate child's age in years
  /// Returns: Number of complete years
  int get ageInYears {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    
    // If birthday hasn't happened this year yet, subtract 1
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    
    return years;
  }

  /// Create a copy of this Child with some fields changed 
  /// Useful for updating specific fields while keeping others the same.

  Child copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? parentId,
    DateTime? createdAt,
    bool? isSyncedToBackend,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      isSyncedToBackend: isSyncedToBackend ?? this.isSyncedToBackend,
    );
  }
}