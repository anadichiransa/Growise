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
    _connectivity.onConnectivityRestored(_syncPendingRecordsToBackend);
  }

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  Future<GrowthRecord> saveRecord(GrowthRecord record) async {
    final recordToSave = GrowthRecord(
      id: record.id,
      childId: record.childId,
      userId: _userId,
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

    final id = await _firestore.saveRecord(recordToSave);

    final saved = GrowthRecord(
      id: id,
      childId: recordToSave.childId,
      userId: recordToSave.userId,
      date: recordToSave.date,
      weight: recordToSave.weight,
      height: recordToSave.height,
      bmi: recordToSave.bmi,
      weightForAgeZ: recordToSave.weightForAgeZ,
      heightForAgeZ: recordToSave.heightForAgeZ,
      category: recordToSave.category,
      recommendations: recordToSave.recommendations,
      notes: recordToSave.notes,
      createdAt: recordToSave.createdAt,
      isSyncedToBackend: false,
    );

    if (_connectivity.isOnline.value) {
      _syncRecordToBackend(saved);
    }

    return saved;
  }

  Future<List<GrowthRecord>> getRecords(String childId) async {
    return await _firestore.getRecords(
      childId: childId,
      userId: _userId,
    );
  }

  Future<void> deleteRecord(String recordId) async {
    await _firestore.deleteRecord(recordId);
  }

  Future<void> _syncRecordToBackend(GrowthRecord record) async {
    try {
      await _api.syncGrowthRecord(record.toJson());
      await _firestore.markSyncedToBackend(record.id);
    } catch (e) {
      print('Background sync skipped (will retry): $e');
    }
  }

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