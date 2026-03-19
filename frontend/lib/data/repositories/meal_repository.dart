import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_plan.dart';
import '../../core/config/api_config.dart';

/// Repository for all AI Meal Planner API calls.
///
/// Uses the standard http package (not Dio) for simplicity.
class MealRepository {
  /// Calls POST /api/v1/meals/generate and returns a MealPlan.
  ///
  /// Throws an [Exception] if:
  ///   - The request times out (>30 seconds)
  ///   - The server returns a non-200 status
  ///   - The response cannot be parsed
  Future<MealPlan> generateMealPlan({
    required int childAgeMonths,
    required List<String> likedFoods,
    required List<String> dislikedFoods,
    required List<String> prepMethods,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/meals/generate');

    final requestBody = jsonEncode({
      'child_age_months': childAgeMonths,
      'liked_foods': likedFoods,
      'disliked_foods': dislikedFoods,
      'prep_methods': prepMethods, // ← carries cooking preference to backend
    });

    late http.Response response;

    try {
      response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(milliseconds: ApiConfig.timeoutMs));
    } on Exception catch (e) {
      // Network error — no connection, DNS failure, etc.
      throw Exception('Network error: $e');
    }

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MealPlan.fromJson(json);
      } catch (e) {
        throw Exception('Failed to parse server response: $e');
      }
    }

    // Non-200 response — extract the error message from the backend JSON
    String errorMessage =
        'Failed to generate meal plan (${response.statusCode})';
    try {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = errorJson['detail'];
      if (detail is Map) {
        errorMessage = detail['message'] as String? ?? errorMessage;
      } else if (detail is String) {
        errorMessage = detail;
      }
    } catch (_) {
      // Could not parse error — use default message
    }

    throw Exception(errorMessage);
  }
}
