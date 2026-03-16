import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/meal_plan.dart';
import '../screens/recipe_detail_screen.dart';

/// Displays a generated meal plan result.
///
/// Shows: recipe name, modification warning (if needed),
/// nutrition summary, ingredients list, AI explanation.
class RecipeCard extends StatelessWidget {
  final MealPlan mealPlan;

  const RecipeCard({super.key, required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Recipe Name Banner ─────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🍽️ Your Meal Plan',
                style: TextStyle(
                  color: Color(0xFFDDD6FE),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mealPlan.recipeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _badge(mealPlan.texture.replaceAll('_', ' ').toUpperCase()),
                  const SizedBox(width: 8),
                  _badge(mealPlan.fhbGuidelineId.replaceAll('_', ' ')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Modification Warning ───────────────────────────────────
        if (mealPlan.modificationRequired) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ MODIFICATION REQUIRED',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Omit or reduce for baby\'s portion: '
                  '${mealPlan.omitOrReduce.map((s) => s.toUpperCase()).join(', ')}',
                  style: const TextStyle(
                    color: Color(0xFF78350F),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'The AI explanation below explains exactly how to do this.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Nutrition Card ─────────────────────────────────────────
        _InfoCard(
          title: '📊 Nutrition per serving',
          children: [
            _NutritionRow('Calories', '${mealPlan.nutrition.calories.toStringAsFixed(0)} kcal'),
            _NutritionRow('Protein',  '${mealPlan.nutrition.proteinG.toStringAsFixed(1)} g'),
            _NutritionRow('Iron',     '${mealPlan.nutrition.ironMg.toStringAsFixed(2)} mg'),
            _NutritionRow('Serving',  '${mealPlan.nutrition.servingSizeG.toStringAsFixed(0)} g'),
            const Divider(height: 16),
            Text(
              '📌 Source: ${mealPlan.nutrition.source}',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Ingredients ────────────────────────────────────────────
        _InfoCard(
          title: '🥘 Ingredients',
          children: mealPlan.ingredients.map((ing) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 16)),
                Expanded(
                  child: Text(
                    ing.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),

        // ── AI Explanation ─────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8B5CF6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🤖 ', style: TextStyle(fontSize: 18)),
                  Text(
                    'AI Nutritionist Says',
                    style: TextStyle(
                      color: Color(0xFF5B21B6),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                mealPlan.aiExplanation,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── View Full Recipe Button ────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Get.to(() => RecipeDetailScreen(mealPlan: mealPlan)),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('View Full Recipe'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5B21B6),
              side: const BorderSide(color: Color(0xFF5B21B6)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}


class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF5B21B6),
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}


class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
        ],
      ),
    );
  }
}
