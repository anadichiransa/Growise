/// Data models for the AI Meal Planner.
///
/// These classes mirror the MealResponse and NutritionInfo
/// Pydantic models in backend/app/models/meal.py.
/// Field names use camelCase in Dart but map from snake_case JSON.

class NutritionInfo {
  final double calories;
  final double proteinG;
  final double ironMg;
  final double servingSizeG;
  final double servingSizeMl;
  final String source;
  final String note;

  const NutritionInfo({
    required this.calories,
    required this.proteinG,
    required this.ironMg,
    required this.servingSizeG,
    required this.servingSizeMl,
    required this.source,
    required this.note,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories:      (json['calories']        as num?)?.toDouble() ?? 0.0,
      proteinG:      (json['protein_g']       as num?)?.toDouble() ?? 0.0,
      ironMg:        (json['iron_mg']         as num?)?.toDouble() ?? 0.0,
      servingSizeG:  (json['serving_size_g']  as num?)?.toDouble() ?? 100.0,
      servingSizeMl: (json['serving_size_ml'] as num?)?.toDouble() ?? 100.0,
      source:        json['source'] as String? ?? '',
      note:          json['note']   as String? ?? '',
    );
  }
}


class MealPlan {
  final String recipeName;
  final List<String> ingredients;
  final String preparation;
  final NutritionInfo nutrition;
  final String aiExplanation;
  final bool modificationRequired;
  final List<String> omitOrReduce;
  final String texture;
  final String fhbGuidelineId;

  const MealPlan({
    required this.recipeName,
    required this.ingredients,
    required this.preparation,
    required this.nutrition,
    required this.aiExplanation,
    required this.modificationRequired,
    required this.omitOrReduce,
    required this.texture,
    required this.fhbGuidelineId,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      recipeName:           json['recipe_name']       as String? ?? '',
      preparation:          json['preparation']       as String? ?? '',
      aiExplanation:        json['ai_explanation']    as String? ?? '',
      texture:              json['texture']           as String? ?? '',
      fhbGuidelineId:       json['fhb_guideline_id']  as String? ?? '',
      modificationRequired: json['modification_required'] as bool? ?? false,
      ingredients:          (json['ingredients']    as List<dynamic>?)
                                ?.map((e) => e.toString()).toList() ?? [],
      omitOrReduce:         (json['omit_or_reduce'] as List<dynamic>?)
                                ?.map((e) => e.toString()).toList() ?? [],
      nutrition:            NutritionInfo.fromJson(
                                json['nutrition'] as Map<String, dynamic>? ?? {}),
    );
  }
}
