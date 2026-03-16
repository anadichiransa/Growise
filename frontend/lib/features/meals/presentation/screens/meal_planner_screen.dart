import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meal_controller.dart';
import '../widgets/recipe_card.dart';
import '../widgets/ingredient_selector.dart';

/// Main AI Meal Planner screen.
///
/// Shows the meal preference form and the generated meal plan result.
/// All state comes from MealController.
class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  static const _foodOptions = [
    'Rice', 'Chicken', 'Dhal', 'Carrot', 'Banana',
    'Sweet Potato', 'Pumpkin', 'Fish', 'Egg',
    'Avocado', 'Papaya', 'Gotukola', 'Breadfruit',
  ];

  static const _prepOptions = [
    'Boiled', 'Steamed', 'Mashed', 'Pureed', 'Baked', 'Fried',
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(MealController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text(
          '✨ AI Meal Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
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

            // ── Internet Requirement Notice ──────────────────────────
            _InternetNotice(),
            const SizedBox(height: 20),

            // ── Age Slider ───────────────────────────────────────────
            _SectionTitle('Baby\'s Age'),
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: ctrl.childAge.value.toDouble(),
                  min: 6, max: 24, divisions: 18,
                  activeColor: const Color(0xFF5B21B6),
                  label: '${ctrl.childAge.value} months',
                  onChanged: (v) => ctrl.childAge.value = v.round(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '${ctrl.childAge.value} months old',
                    style: const TextStyle(
                      color: Color(0xFF5B21B6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 20),

            // ── Liked Foods ──────────────────────────────────────────
            _SectionTitle('Foods Baby Likes ✅'),
            const SizedBox(height: 6),
            Obx(() => IngredientSelector(
              options:        _foodOptions,
              selectedItems:  ctrl.likedFoods,
              onToggle:       ctrl.toggleLiked,
              selectedColor:  const Color(0xFFD1FAE5),
              selectedBorder: const Color(0xFF065F46),
              selectedText:   const Color(0xFF065F46),
            )),
            const SizedBox(height: 20),

            // ── Disliked Foods ───────────────────────────────────────
            _SectionTitle('Foods Baby Refuses ❌'),
            const SizedBox(height: 4),
            const Text(
              'These will be filtered out — your baby will never see them.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 6),
            Obx(() => IngredientSelector(
              options:        _foodOptions,
              selectedItems:  ctrl.dislikedFoods,
              onToggle:       ctrl.toggleDisliked,
              selectedColor:  const Color(0xFFFEE2E2),
              selectedBorder: const Color(0xFF991B1B),
              selectedText:   const Color(0xFF991B1B),
            )),
            const SizedBox(height: 20),

            // ── Cooking Methods ──────────────────────────────────────
            _SectionTitle('How Do You Prefer to Cook? 🍳'),
            const SizedBox(height: 4),
            const Text(
              'The AI will give you advice about the healthiest cooking method for your baby.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 6),
            Obx(() => IngredientSelector(
              options:        _prepOptions,
              selectedItems:  ctrl.prepMethods,
              onToggle:       ctrl.togglePrepMethod,
              selectedColor:  const Color(0xFFDBEAFE),
              selectedBorder: const Color(0xFF1D4ED8),
              selectedText:   const Color(0xFF1D4ED8),
            )),
            const SizedBox(height: 32),

            // ── Generate Button ──────────────────────────────────────
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.isLoading.value ? null : ctrl.generateMealPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B21B6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF9CA3AF),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: ctrl.isLoading.value
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Finding the perfect recipe...',
                            style: TextStyle(fontSize: 13),
                          ),
                          Text(
                            'This can take 10-20 seconds',
                            style: TextStyle(fontSize: 11, color: Color(0xFFE5E7EB)),
                          ),
                        ],
                      )
                    : const Text(
                        '✨ Generate Meal Plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            )),
            const SizedBox(height: 16),

            // ── Error Display ────────────────────────────────────────
            Obx(() {
              if (ctrl.error.value.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF87171)),
                ),
                child: Text(
                  ctrl.error.value,
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    height: 1.5,
                  ),
                ),
              );
            }),

            // ── Meal Plan Result ─────────────────────────────────────
            Obx(() {
              final plan = ctrl.mealPlan.value;
              if (plan == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: RecipeCard(mealPlan: plan),
              );
            }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


// ── Private Helper Widgets ────────────────────────────────────────────────────

class _InternetNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFACC15)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_rounded, color: Color(0xFFB45309), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI Meal Planner requires internet. Powered by Groq AI + Sri Lankan recipe database.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF78350F),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Color(0xFF1F2937),
      ),
    );
  }
}
