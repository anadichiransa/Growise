import '../data/models/growth_record_model.dart';
import '../data/repositories/api_service.dart';

class GrowthController {

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<List<GrowthRecord>> loadRecords(String childId) async {
    try {
      final records = await ApiService.getGrowthRecords(childId);
      return records.map((r) => GrowthRecord.fromJson(r)).toList();
    } catch (e) {
      print('Error loading records: $e');
      return [];
    }
  }

  // ── Add ────────────────────────────────────────────────────────────────────

  Future<bool> addMeasurement({
    required String childId,
    required String gender,
    required DateTime dateOfBirth,
    required DateTime date,
    required double weight,
    required double height,
    String measuredAt = 'home',
    String? notes,
  }) async {
    try {
      await ApiService.addMeasurement(
        childId:      childId,
        gender:       gender,
        dateOfBirth:  dateOfBirth.toIso8601String(),
        date:         date.toIso8601String(),
        weight:       weight,
        height:       height,
        measuredAt:   measuredAt,
        notes:        notes,
      );
      return true;
    } catch (e) {
      print('Error adding measurement: $e');
      return false;
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<bool> updateRecord({
    required String recordId,
    required String childId,
    required String gender,
    required DateTime dateOfBirth,
    required DateTime date,
    required double weight,
    required double height,
    String measuredAt = 'home',
    String? notes,
  }) async {
    try {
      await ApiService.updateMeasurement(
        recordId:     recordId,
        childId:      childId,
        gender:       gender,
        dateOfBirth:  dateOfBirth.toIso8601String(),
        date:         date.toIso8601String(),
        weight:       weight,
        height:       height,
        measuredAt:   measuredAt,
        notes:        notes,
      );
      return true;
    } catch (e) {
      print('Error updating record: $e');
      return false;
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<bool> deleteRecord(String recordId, String childId) async {
    try {
      await ApiService.deleteMeasurement(recordId);
      return true;
    } catch (e) {
      print('Error deleting record: $e');
      return false;
    }
  }

  // ── Summary & Recommendations ──────────────────────────────────────────────

  String generateSummary({
    required String category,
    required double? weightZ,
    required double? heightZ,
    required String childName,
  }) {
    switch (category) {
      case 'healthy':
        return 'Great news! $childName\'s growth is healthy and within the normal WHO range.';
      case 'stunting':
        return '$childName\'s height is below expected (z-score: ${heightZ?.toStringAsFixed(1)}). Please consult your PHM.';
      case 'severe_stunting':
        return '⚠️ $childName\'s height is significantly below expected. Please see a doctor immediately.';
      case 'wasting':
        return '$childName\'s weight is below expected (z-score: ${weightZ?.toStringAsFixed(1)}). Please consult your PHM.';
      case 'severe_wasting':
        return '⚠️ $childName\'s weight is significantly below expected. Please see a doctor immediately.';
      case 'overweight':
        return '$childName\'s weight is above the normal range. Focus on balanced meals.';
      default:
        return 'Growth data recorded.';
    }
  }

  List<String> getRecommendations(String category) {
    switch (category) {
      case 'healthy':
        return [
          'Continue with the current feeding routine',
          'Maintain regular check-ups with your PHM',
          'Ensure balanced, nutritious meals',
        ];
      case 'stunting':
      case 'severe_stunting':
        return [
          'Consult your PHM or pediatrician within 48 hours',
          'Increase meal frequency to 5–6 times daily',
          'Focus on protein-rich foods (eggs, dhal, fish)',
          'Monitor growth weekly',
        ];
      case 'wasting':
      case 'severe_wasting':
        return [
          'Consult a doctor immediately',
          'Increase calorie intake with energy-dense foods',
          'Monitor weight every 3 days',
          'Rule out any underlying illness',
        ];
      case 'overweight':
        return [
          'Reduce sugary drinks and snacks',
          'Increase age-appropriate physical activity',
          'Focus on whole foods — fruits and vegetables',
        ];
      default:
        return [];
    }
  }
}