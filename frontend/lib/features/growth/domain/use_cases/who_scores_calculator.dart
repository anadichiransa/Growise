import 'dart:math';
import 'who_data.dart';

/// Result of a WHO growth analysis
class WHOResult {
  final double? weightForAgeZ;
  final double? heightForAgeZ;
  final String category;
  final String summary;
  final List<String> recommendations;
  final double? bmi;

  const WHOResult({
    this.weightForAgeZ,
    this.heightForAgeZ,
    required this.category,
    required this.summary,
    required this.recommendations,
    this.bmi,
  });
}

// calculate WHO z-scores and growth category.
class WhoScoresCalculator {
  /// Main entry point. to be called from the controller.
  ///
  /// [weight]    Weight in kg
  /// [height]    Height in cm
  /// [ageInMonths] Age in completed months
  /// [gender]    'male' or 'female'
  /// [childName] Used for building the summary message
  WHOResult call({
    required double weight,
    required double height,
    required int ageInMonths,
    required String gender,
    required String childName,
  }) {
    final weightZ = _calculateWeightForAge(weight, ageInMonths, gender);
    final heightZ = _calculateHeightForAge(height, ageInMonths, gender);
    final category = _categorize(weightZ, heightZ);
    final bmi = _calculateBMI(weight, height);

    return WHOResult(
      weightForAgeZ: weightZ,
      heightForAgeZ: heightZ,
      category: category,
      summary: _buildSummary(category, weightZ, heightZ, childName),
      recommendations: _getRecommendations(category),
      bmi: bmi,
    );
  }

  // ─── Z-score formula ────────────────────────────────────────────────────────

  /// WHO LMS formula: Z = ((value/M)^L − 1) / (L × S)
  /// Special case when L = 0: Z = ln(value/M) / S
  double _zScore(double value, double L, double M, double S) {
    if (L == 0) return log(value / M) / S;
    return (pow(value / M, L) - 1) / (L * S);
  }

  double? _calculateWeightForAge(
    double weight,
    int ageInMonths,
    String gender,
  ) {
    if (ageInMonths < 0 || ageInMonths > 60) return null;
    final table = gender.toLowerCase() == 'male'
        ? WHOData.weightForAgeBoys
        : WHOData.weightForAgeGirls;
    final lms = table[ageInMonths];
    if (lms == null) return null;
    return _zScore(weight, lms['L']!, lms['M']!, lms['S']!);
  }

  double? _calculateHeightForAge(
    double height,
    int ageInMonths,
    String gender,
  ) {
    if (ageInMonths < 0 || ageInMonths > 60) return null;
    final table = gender.toLowerCase() == 'male'
        ? WHOData.heightForAgeBoys
        : WHOData.heightForAgeGirls;
    final lms = table[ageInMonths];
    if (lms == null) return null;
    return _zScore(height, lms['L']!, lms['M']!, lms['S']!);
  }

  double _calculateBMI(double weight, double height) {
    final heightM = height / 100;
    return weight / (heightM * heightM);
  }

  String _categorize(double? weightZ, double? heightZ) {
    if (heightZ != null && heightZ < -3) return 'severe_stunting';
    if (weightZ != null && weightZ < -3) return 'severe_wasting';
    if (heightZ != null && heightZ < -2) return 'stunting';
    if (weightZ != null && weightZ < -2) return 'wasting';
    if (weightZ != null && weightZ > 2) return 'overweight';
    return 'healthy';
  }
}
