import 'package:get/get.dart';
import '../../../../data/models/meal_plan.dart';
import '../../../../data/repositories/meal_repository.dart';
import '../../domain/use_cases/generate_meal_plan.dart';

/// GetX controller for the AI Meal Planner.
///
/// Holds all state and orchestrates the generate flow.
/// The screen observes reactive variables with Obx().
class MealController extends GetxController {

  // Dependencies
  final MealRepository _repository = MealRepository();
  late final GenerateMealPlan _generateMealPlan = GenerateMealPlan(_repository);

  // ── Reactive State ───────────────────────────────────────────────

  /// Child's age in months — drives the slider (6-24)
  final RxInt childAge = 8.obs;

  /// Foods the baby likes — bias recipe search toward these
  final RxList<String> likedFoods = <String>[].obs;

  /// Foods the baby refuses — hard-filtered out in backend Python
  final RxList<String> dislikedFoods = <String>[].obs;

  /// Mother's preferred cooking methods — triggers AI cooking education
  final RxList<String> prepMethods = <String>[].obs;

  /// True while waiting for the backend response
  final RxBool isLoading = false.obs;

  /// Error message to display (empty string = no error)
  final RxString error = ''.obs;

  /// The meal plan returned by the backend (null = not generated yet)
  final Rx<MealPlan?> mealPlan = Rx<MealPlan?>(null);

  // ── Toggle Helpers ───────────────────────────────────────────────

  void _toggle(String item, RxList<String> list) {
    if (list.contains(item)) {
      list.remove(item);
    } else {
      list.add(item);
    }
  }

  /// Toggle a food in the liked list.
  void toggleLiked(String food) => _toggle(food, likedFoods);

  /// Toggle a food in the disliked list.
  void toggleDisliked(String food) => _toggle(food, dislikedFoods);

  /// Toggle a cooking method in the prep methods list.
  void togglePrepMethod(String method) => _toggle(method, prepMethods);

  // ── Main Action ──────────────────────────────────────────────────

  /// Generate a meal plan by calling the backend.
  ///
  /// Updates isLoading, error, and mealPlan reactively.
  Future<void> generateMealPlan() async {
    // Guard: don't start if already loading
    if (isLoading.value) return;

    isLoading.value = true;
    error.value     = '';
    mealPlan.value  = null;

    try {
      final result = await _generateMealPlan(
        childAgeMonths: childAge.value,
        likedFoods:     List<String>.from(likedFoods),
        dislikedFoods:  List<String>.from(dislikedFoods),
        prepMethods:    List<String>.from(prepMethods),
      );

      mealPlan.value = result;

    } on Exception catch (e) {
      // Parse the error message and show a human-friendly version
      final raw = e.toString().replaceFirst('Exception: ', '');

      String friendlyMessage;

      if (raw.contains('SocketException') ||
          raw.contains('Network error') ||
          raw.contains('Connection refused')) {
        friendlyMessage =
            '📶 No connection to server.\n'
            'Make sure the backend is running and check the URL in api_config.dart.';
      } else if (raw.contains('TimeoutException') ||
                 raw.contains('timed out')) {
        friendlyMessage =
            '⏱ Request timed out.\n'
            'The AI can take 10-20 seconds. Please try again.';
      } else if (raw.contains('No matching') ||
                 raw.contains('All available recipes')) {
        friendlyMessage =
            '🥗 No recipes found with those preferences.\n'
            'Try removing some disliked foods or changing the age.';
      } else if (raw.contains('No recipes found')) {
        friendlyMessage =
            '⚠️ Database may be empty.\n'
            'Run ingest_into_chromadb.py on the backend.';
      } else {
        friendlyMessage = '❌ Something went wrong.\nDetails: $raw';
      }

      error.value = friendlyMessage;

      // Also show a snackbar for immediate feedback
      Get.snackbar(
        'Error',
        friendlyMessage.split('\n').first,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

    } finally {
      isLoading.value = false;
    }
  }
}
