import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/growth_record.dart';
import '../../../../data/repositories/growth_repository.dart';
import '../../domain/use_cases/calculate_who_scores.dart';

class GrowthController extends GetxController {
  final GrowthRepository _repository = GrowthRepository();
  final CalculateWHOScores _whoCalculator = CalculateWHOScores();

  // ─── Reactive state ───────────────────────────────────────────────────────────
  var growthRecords = <GrowthRecord>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ─── Derived state ────────────────────────────────────────────────────────────
  GrowthRecord? get latestRecord =>
      growthRecords.isNotEmpty ? growthRecords.first : null;

  String get currentStatus => latestRecord?.category ?? 'unknown';

  List<String> get currentRecommendations =>
      latestRecord?.recommendations ?? [];

  // ─── Actions ──────────────────────────────────────────────────────────────────

  /// Load records from Firestore (uses cache when offline).
  Future<void> loadRecords(String childId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final records = await _repository.getRecords(childId);
      growthRecords.value = records;
    } catch (e) {
      errorMessage.value = 'Failed to load records: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new measurement.
  ///
  /// WHO calculations happen here in Flutter (offline-safe).
  /// Firestore save happens here (offline-safe via SDK cache).
  /// Backend sync happens in background (won't block or error on failure).
  Future<bool> addMeasurement({
    required String childId,
    required String childName,
    required DateTime childBirthDate,
    required String childGender,
    required DateTime date,
    required double weight,
    required double height,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Step 1: Calculate age
      final ageMonths = _calculateAgeInMonths(childBirthDate, date);

      // Step 2: WHO calculations (pure Dart, no network, always works)
      final result = _whoCalculator(
        weight: weight,
        height: height,
        ageMonths: ageMonths,
        gender: childGender,
        childName: childName,
      );

      // Step 3: Build record with full analysis already included
      final record = GrowthRecord(
        id: '',  // Firestore will assign
        childId: childId,
        userId: FirebaseAuth.instance.currentUser!.uid,
        date: date,
        weight: weight,
        height: height,
        bmi: result.bmi,
        weightForAgeZ: result.weightForAgeZ,
        heightForAgeZ: result.heightForAgeZ,
        category: result.category,
        recommendations: result.recommendations,
        notes: notes,
        createdAt: DateTime.now(),
      );

      // Step 4: Save (Firestore-first, backend in background)
      final saved = await _repository.saveRecord(record);

      // Step 5: Insert at top of list — UI updates immediately
      growthRecords.insert(0, saved);

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to save measurement: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a record.
  Future<bool> deleteRecord(String recordId) async {
    try {
      isLoading.value = true;
      await _repository.deleteRecord(recordId);
      growthRecords.removeWhere((r) => r.id == recordId);
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to delete record: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Human-readable summary for the status banner.
  String getSummary(String childName) {
    if (latestRecord == null) {
      return 'No measurements recorded yet. Add your first measurement to start tracking.';
    }
    // Summary was built by CalculateWHOScores and stored in the record
    // Re-generate from category for display (avoids storing long strings in Firestore)
    final result = _whoCalculator(
      weight: latestRecord!.weight,
      height: latestRecord!.height,
      ageMonths: 0, // not used for summary regeneration — pass stored z-scores instead
      gender: 'male', // placeholder
      childName: childName,
    );
    // Actually — just return a simple message based on the stored category
    return _summaryFromCategory(latestRecord!.category ?? 'unknown', childName,
        latestRecord!.weightForAgeZ, latestRecord!.heightForAgeZ);
  }

  String _summaryFromCategory(
    String category, String childName, double? weightZ, double? heightZ) {
    switch (category) {
      case 'healthy':
        return 'Great news! $childName\'s growth is healthy according to WHO standards.';
      case 'stunting':
        return '$childName\'s height is below expected (z-score: ${heightZ?.toStringAsFixed(1)}). Please consult your PHM.';
      case 'severe_stunting':
        return '⚠️ $childName\'s height is significantly below expected (z-score: ${heightZ?.toStringAsFixed(1)}). See a doctor immediately.';
      case 'wasting':
        return '$childName\'s weight is below expected (z-score: ${weightZ?.toStringAsFixed(1)}). Please consult your PHM.';
      case 'severe_wasting':
        return '⚠️ $childName\'s weight is significantly below expected (z-score: ${weightZ?.toStringAsFixed(1)}). See a doctor immediately.';
      case 'overweight':
        return '$childName\'s weight is above expected (z-score: ${weightZ?.toStringAsFixed(1)}). Focus on balanced meals.';
      default:
        return 'Growth data analysed.';
    }
  }

  // Utility

  int _calculateAgeInMonths(DateTime birthDate, DateTime measurementDate) {
    int months = (measurementDate.year - birthDate.year) * 12;
    months += measurementDate.month - birthDate.month;
    if (measurementDate.day < birthDate.day) months--;
    return months;
  }
}