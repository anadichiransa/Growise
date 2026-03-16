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

  String _buildSummary(
    String category,
    double? weightZ,
    double? heightZ,
    String childName,
  ) {
    switch (category) {
      case 'healthy':
        return 'Great news! $childName\'s growth is healthy. '
            'Both weight and height are within the normal range '
            'according to WHO standards.';
      case 'stunting':
        return '$childName\'s height is below expected for their age '
            '(z-score: ${heightZ?.toStringAsFixed(1)}). '
            'This may indicate chronic undernutrition. '
            'Please consult your PHM for guidance.';
      case 'severe_stunting':
        return '⚠️ $childName\'s height is significantly below expected '
            '(z-score: ${heightZ?.toStringAsFixed(1)}). '
            'Please consult your doctor immediately.';
      case 'wasting':
        return '$childName\'s weight is below expected for their age '
            '(z-score: ${weightZ?.toStringAsFixed(1)}). '
            'This may indicate recent illness or acute malnutrition. '
            'Please consult your PHM.';
      case 'severe_wasting':
        return '⚠️ $childName\'s weight is significantly below expected '
            '(z-score: ${weightZ?.toStringAsFixed(1)}). '
            'Please consult your doctor immediately.';
      case 'overweight':
        return '$childName\'s weight is above expected for their age '
            '(z-score: ${weightZ?.toStringAsFixed(1)}). '
            'Focus on healthy, balanced meals.';
      default:
        return 'Growth data analysed.';
    }
  }

  List<String> _getRecommendations(String category) {
    switch (category) {
      case 'healthy':
        return [
          'Continue with current feeding routine',
          'Maintain regular check-ups',
          'Ensure balanced, nutritious meals',
        ];
      case 'stunting':
      case 'severe_stunting':
        return [
          'Consult PHM or paediatrician within 48 hours',
          'Increase meal frequency to 5–6 times daily',
          'Focus on protein-rich foods (eggs, dhal, fish)',
          'Use the meal planner for nutrient-dense recipes',
          'Monitor growth weekly',
        ];
      case 'wasting':
      case 'severe_wasting':
        return [
          'Consult doctor immediately',
          'Increase calorie intake',
          'Add energy-dense foods (coconut oil, nut pastes)',
          'Monitor weight every 3 days',
          'Rule out underlying illness',
        ];
      case 'overweight':
        return [
          'Reduce sugary drinks and snacks',
          'Increase physical activity (age-appropriate)',
          'Focus on whole foods (fruits, vegetables)',
          'Avoid processed foods',
          'Consult a nutritionist if it continues',
        ];
      default:
        return [];
    }
  }
}
