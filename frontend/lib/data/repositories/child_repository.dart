import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/child.dart';
import '../providers/api_provider.dart';

/// Repository for managing child data
/// Handles all Firestore operations for child profiles
class ChildRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiProvider _apiProvider = ApiProvider();

  /// Collection reference
  CollectionReference get _childrenCollection => 
      _firestore.collection('children');

  /// Get current user's ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Save child to Firestore
  /// 
  /// Creates new document with auto-generated ID.
  /// Works offline - syncs when connection restored.
  Future<String> saveChild({
    required String name,
    required DateTime birthDate,
    required String gender,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Create child object
    final docRef = _childrenCollection.doc(); // Auto-generate ID
    final child = Child(
      id: docRef.id,
      name: name,
      birthDate: birthDate,
      gender: gender,
      parentId: _currentUserId!,
      createdAt: DateTime.now(),
      isSyncedToBackend: false,
    );

    // Save to Firestore
    await docRef.set(child.toFirestore());
    _syncToBackend(child);
    return docRef.id;
  }

  /// Sync to backend (runs in background)
void _syncToBackend(Child child) async {
  try {
    final success = await _apiProvider.syncChild(child.toJson());
    if (success) {
      await markAsSynced(child.id);
    }
  } catch (e) {
    // Silent failure - will retry on next app start
    print('Background sync failed: $e');
  }
}


  /// Get all children for current user
  Future<List<Child>> getChildren() async {
    if (_currentUserId == null) return [];

    final snapshot = await _childrenCollection
        .where('parentId', isEqualTo: _currentUserId)
        .get();

    return snapshot.docs
        .map((doc) => Child.fromFirestore(doc))
        .toList();
  }

  /// Update sync status
  Future<void> markAsSynced(String childId) async {
    await _childrenCollection.doc(childId).update({
      'isSyncedToBackend': true,
    });
  }
}