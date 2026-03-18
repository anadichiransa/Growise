import 'package:flutter/material.dart';
import '../../../../data/models/meal_plan.dart';

/// Full-screen recipe detail view.
///
/// Shown when the user taps "View Full Recipe" on the RecipeCard.
class RecipeDetailScreen extends StatelessWidget {
  final MealPlan mealPlan;

  const RecipeDetailScreen({super.key, required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: Text(
          mealPlan.recipeName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF5B21B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Texture + Guideline badges
            Wrap(
              spacing: 8,
              children: [
                _Chip(mealPlan.texture.replaceAll('_', ' ').toUpperCase(), const Color(0xFF5B21B6)),
                _Chip(mealPlan.fhbGuidelineId.replaceAll('_', ' '), const Color(0xFF065F46)),
              ],
            ),
            const SizedBox(height: 20),

            // Modification warning
            if (mealPlan.modificationRequired) ...[
              _WarningBox(
                '⚠️ MODIFICATION REQUIRED',
                'Remove or reduce for baby\'s portion: '
                '${mealPlan.omitOrReduce.map((s) => s.toUpperCase()).join(', ')}',
              ),
              const SizedBox(height: 16),
            ],

            // Preparation method
            _Section(
              '🍳 Preparation Method',
              [Text(mealPlan.preparation, style: const TextStyle(fontSize: 14, height: 1.5))],
            ),
            const SizedBox(height: 16),

            // Ingredients
            _Section(
              '🥘 Ingredients',
              mealPlan.ingredients.map((ing) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 16)),
                  Text(ing.replaceAll('_', ' '), style: const TextStyle(fontSize: 14)),
                ]),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // Nutrition
            _Section(
              '📊 Nutrition',
              [
                _NRow('Calories', '${mealPlan.nutrition.calories.toStringAsFixed(0)} kcal'),
                _NRow('Protein',  '${mealPlan.nutrition.proteinG.toStringAsFixed(1)} g'),
                _NRow('Iron',     '${mealPlan.nutrition.ironMg.toStringAsFixed(2)} mg'),
                _NRow('Serving',  '${mealPlan.nutrition.servingSizeG.toStringAsFixed(0)} g'),
                const SizedBox(height: 8),
                Text(
                  mealPlan.nutrition.note,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // AI Explanation
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
                  const Text(
                    '🤖 AI Nutritionist Advice',
                    style: TextStyle(
                      color: Color(0xFF5B21B6),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mealPlan.aiExplanation,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


class _Chip extends StatelessWidget {
  final String label;
  final Color  color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}


class _Section extends StatelessWidget {
  final String       title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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


class _WarningBox extends StatelessWidget {
  final String title, body;
  const _WarningBox(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF92400E),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(color: Color(0xFF78350F), fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}


class _NRow extends StatelessWidget {
  final String label, value;
  const _NRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
