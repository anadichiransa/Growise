import '../../../../data/models/meal_plan.dart';
import '../../../../data/repositories/meal_repository.dart';

/// Use case for generating a meal plan.
///
/// Sits between MealController and MealRepository.
/// Controller calls this — never calls the repository directly.
class GenerateMealPlan {
  final MealRepository _repository;

  GenerateMealPlan(this._repository);

  /// Execute the use case.
  ///
  /// Returns a [MealPlan] on success.
  /// Throws an [Exception] on failure (network error, no recipe, etc.)
  Future<MealPlan> call({
    required int childAgeMonths,
    required List<String> likedFoods,
    required List<String> dislikedFoods,
    required List<String> prepMethods,
  }) async {
    return _repository.generateMealPlan(
      childAgeMonths: childAgeMonths,
      likedFoods:     likedFoods,
      dislikedFoods:  dislikedFoods,
      prepMethods:    prepMethods,
    );
  }
}
