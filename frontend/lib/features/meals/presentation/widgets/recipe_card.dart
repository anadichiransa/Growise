import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/meal_plan.dart';
import '../screens/recipe_detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final MealPlan mealPlan;
  const RecipeCard({super.key, required this.mealPlan});

  static const _bg      = Color(0xFF2D1B4E);
  static const _accent  = Color(0xFFD4A017);
  static const _purple  = Color(0xFF7C3AED);
  static const _textSub = Color(0xFFB39DDB);
  static const _soft    = Color(0xFF3D2069);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Chat bubble label ────────────────────────────────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Nutrition Bot',
              style: TextStyle(color: Colors.white70,
                fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),

        // ── Recipe name card ─────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🍽️ Your Meal Plan',
                style: TextStyle(color: Color(0xFFDDD6FE),
                  fontSize: 11, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(mealPlan.recipeName,
                style: const TextStyle(color: Colors.white,
                  fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _darkBadge(mealPlan.texture.replaceAll('_', ' ').toUpperCase()),
                  _darkBadge(mealPlan.fhbGuidelineId.replaceAll('_', ' ')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Modification warning ─────────────────────────────────────
        if (mealPlan.modificationRequired) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF3B2000),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️ MODIFICATION REQUIRED',
                  style: TextStyle(color: Color(0xFFD4A017),
                    fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  'Omit for baby\'s portion: '
                  '${mealPlan.omitOrReduce.map((s) => s.toUpperCase()).join(', ')}',
                  style: const TextStyle(color: Colors.white70,
                    fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Nutrition card ───────────────────────────────────────────
        _DarkCard(
          title: '📊 Nutrition per serving',
          accentColor: _accent,
          children: [
            _NRow('Calories', '${mealPlan.nutrition.calories.toStringAsFixed(0)} kcal'),
            _NRow('Protein',  '${mealPlan.nutrition.proteinG.toStringAsFixed(1)} g'),
            _NRow('Iron',     '${mealPlan.nutrition.ironMg.toStringAsFixed(2)} mg'),
            _NRow('Serving',  '${mealPlan.nutrition.servingSizeG.toStringAsFixed(0)} g'),
            const Divider(color: Color(0xFF3D2069), height: 16),
            Text('📌 ${mealPlan.nutrition.source}',
              style: const TextStyle(color: _textSub,
                fontSize: 10, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 10),

        // ── Ingredients ──────────────────────────────────────────────
        _DarkCard(
          title: '🥘 Ingredients',
          accentColor: _accent,
          children: mealPlan.ingredients.map((ing) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Container(width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: _accent, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(ing.replaceAll('_', ' '),
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),

        // ── AI Explanation (chat bubble style) ───────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _purple.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text('🤖 ', style: TextStyle(fontSize: 16)),
                  Text('AI Nutritionist Says',
                    style: TextStyle(color: Color(0xFFB39DDB),
                      fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              Text(mealPlan.aiExplanation,
                style: const TextStyle(color: Colors.white,
                  fontSize: 13, height: 1.7)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── View Full Recipe button ──────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Get.to(() => RecipeDetailScreen(mealPlan: mealPlan)),
            icon: const Icon(Icons.open_in_new, size: 15),
            label: const Text('View Full Recipe →'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _accent,
              side: const BorderSide(color: Color(0xFFD4A017)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _darkBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
        style: const TextStyle(color: Colors.white,
          fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}


class _DarkCard extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<Widget> children;
  const _DarkCard({required this.title, required this.accentColor,
    required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B4E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3D2069)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: TextStyle(color: accentColor,
              fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          ...children,
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(
            color: Color(0xFFB39DDB), fontWeight: FontWeight.w500, fontSize: 13)),
          Text(value, style: const TextStyle(
            color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}