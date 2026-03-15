import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/growth_record.dart';

/// Low-level Firestore operations for growth records.
/// Firestore SDK automatically handles offline caching and sync.
class FirebaseGrowthProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _collection = 'growthRecords';

  /// Save a new growth record. Works offline — SDK queues if no connection.
  Future<String> saveRecord(GrowthRecord record) async {
    final docRef = await _db.collection(_collection).add(record.toFirestore());
    return docRef.id;
  }

  /// Get all records for a child, sorted by date descending.
  /// Returns cached data when offline.
  Future<List<GrowthRecord>> getRecords({
    required String childId,
    required String userId,
  }) async {
    final snapshot = await _db
        .collection(_collection)
        .where('childId', isEqualTo: childId)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get(
          // GetOptions tells Firestore to use cache if server is unreachable
          const GetOptions(source: Source.serverAndCache),
        );

    return snapshot.docs.map((doc) => GrowthRecord.fromFirestore(doc)).toList();
  }

  /// Delete a record. Works offline — SDK queues deletion.
  Future<void> deleteRecord(String recordId) async {
    await _db.collection(_collection).doc(recordId).delete();
  }

  /// Mark a record as synced to backend.
  Future<void> markSyncedToBackend(String recordId) async {
    await _db
        .collection(_collection)
        .doc(recordId)
        .update({'isSyncedToBackend': true});
  }

  /// Get records not yet synced to backend (for background sync).
  Future<List<GrowthRecord>> getUnsyncedRecords({
    required String userId,
  }) async {
    final snapshot = await _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isSyncedToBackend', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) => GrowthRecord.fromFirestore(doc)).toList();
  }

  /// Real-time stream of records .
  Stream<List<GrowthRecord>> watchRecords({
    required String childId,
    required String userId,
  }) {
    return _db
        .collection(_collection)
        .where('childId', isEqualTo: childId)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => GrowthRecord.fromFirestore(doc)).toList());
  }
}
