import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/growth_record.dart';
import '../providers/firebase_provider.dart';
import '../providers/api_provider.dart';
import '../../shared/services/connectivity_service.dart';

class GrowthRepository {
  final FirebaseGrowthProvider _firestore = FirebaseGrowthProvider();
  final ApiProvider _api = ApiProvider();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  GrowthRepository() {
    // When connectivity is restored, sync any records not yet on the backend
    _connectivity.onConnectivityRestored(_syncPendingRecordsToBackend);
  }

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // Primary operations (Firestore — offline-safe)

  /// Save a record. Always saves to Firestore first (works offline).
  /// Attempts background sync to backend if online.
  Future<GrowthRecord> saveRecord(GrowthRecord record) async {
    //Save to Firestore (local cache + cloud when online)
    final id = await _firestore.saveRecord(record);
    final saved = GrowthRecord(
      id: id,
      childId: record.childId,
      userId: record.userId,
      date: record.date,
      weight: record.weight,
      height: record.height,
      bmi: record.bmi,
      weightForAgeZ: record.weightForAgeZ,
      heightForAgeZ: record.heightForAgeZ,
      category: record.category,
      recommendations: record.recommendations,
      notes: record.notes,
      createdAt: record.createdAt,
      isSyncedToBackend: false,
    );

    // Attempt background sync to backend (non-blocking, silent failure)
    if (_connectivity.isOnline.value) {
      _syncRecordToBackend(saved);
    }

    return saved;
  }

  /// Fetch all records for a child. Returns cached data when offline.
  Future<List<GrowthRecord>> getRecords(String childId) async {
    return await _firestore.getRecords(
      childId: childId,
      userId: _userId,
    );
  }

  /// Delete a record from Firestore. Works offline — SDK queues deletion.
  Future<void> deleteRecord(String recordId) async {
    await _firestore.deleteRecord(recordId);
  }

  //  Background backend sync

  /// Send a single record to the FastAPI backend.
  /// Called in background — does not affect the user if it fails.
  Future<void> _syncRecordToBackend(GrowthRecord record) async {
    try {
      await _api.post('/growth/records', record.toJson());
      // Mark as synced in Firestore
      await _firestore.markSyncedToBackend(record.id);
    } catch (e) {
      // Swallow error — record stays in Firestore, sync retried on next
      // connectivity restoration via the _syncPendingRecordsToBackend callback
      print('Background sync skipped (will retry): $e');
    }
  }

  /// Called when connectivity is restored.
  /// Finds all records not yet on the backend and sends them.
  Future<void> _syncPendingRecordsToBackend() async {
    try {
      final unsynced = await _firestore.getUnsyncedRecords(userId: _userId);
      for (final record in unsynced) {
        await _syncRecordToBackend(record);
      }
    } catch (e) {
      print('Bulk sync error: $e');
    }
  }
}