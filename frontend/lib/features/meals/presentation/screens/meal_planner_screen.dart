import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meal_controller.dart';
import '../widgets/ingredient_selector.dart';
import '../widgets/recipe_card.dart';

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  static const _bg         = Color(0xFF1A0A2E);
  static const _card       = Color(0xFF2D1B4E);
  static const _accent     = Color(0xFFD4A017);
  static const _purple     = Color(0xFF7C3AED);
  static const _softPurple = Color(0xFF3D2069);
  static const _textMain   = Colors.white;
  static const _textSub    = Color(0xFFB39DDB);
  static const _online     = Color(0xFF4CAF50);

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
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: const Icon(Icons.menu, color: _textMain),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8,
              decoration: const BoxDecoration(color: _online, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('ONLINE',
              style: TextStyle(color: _textMain, fontWeight: FontWeight.bold,
                fontSize: 14, letterSpacing: 1.2)),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(radius: 18, backgroundColor: _softPurple,
              child: const Icon(Icons.person, color: _textSub, size: 20)),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Hero ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: _softPurple, shape: BoxShape.circle),
                      child: const Icon(Icons.history, color: _textSub, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Robot avatar with glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(color: _purple.withOpacity(0.5),
                              blurRadius: 24, spreadRadius: 4)
                          ],
                        ),
                        child: const Icon(Icons.smart_toy_rounded,
                          color: Colors.white, size: 56),
                      ),
                      Positioned(
                        bottom: 4, right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
                          child: const Icon(Icons.restaurant_menu,
                            color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text("Hello, I'm your",
                    style: TextStyle(color: _textSub, fontSize: 18)),
                  const Text('Nutrition Guide!',
                    style: TextStyle(color: _accent, fontSize: 26,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                    'Tailoring health advice for Sri Lankan child\ndevelopment with data-driven precision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _textSub, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Preferences Card ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Age header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('DAILY SUGGESTION',
                        style: TextStyle(color: _accent, fontWeight: FontWeight.bold,
                          fontSize: 12, letterSpacing: 1.1)),
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: _softPurple,
                          borderRadius: BorderRadius.circular(20)),
                        child: Text('For Age: ${ctrl.childAge.value} Months+',
                          style: const TextStyle(color: _textSub, fontSize: 11,
                            fontWeight: FontWeight.w600)),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Age slider
                  Obx(() => SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _accent,
                      inactiveTrackColor: _softPurple,
                      thumbColor: _accent,
                      overlayColor: _accent.withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: ctrl.childAge.value.toDouble(),
                      min: 6, max: 24, divisions: 18,
                      label: '${ctrl.childAge.value} months',
                      onChanged: (v) => ctrl.childAge.value = v.round(),
                    ),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('6 months', style: TextStyle(color: _textSub, fontSize: 11)),
                      Text('24 months', style: TextStyle(color: _textSub, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Liked foods
                  _FormLabel('Foods Baby Likes', Icons.favorite_rounded, const Color(0xFF4CAF50)),
                  const SizedBox(height: 8),
                  Obx(() => IngredientSelector(
                    options: _foodOptions, selectedItems: ctrl.likedFoods,
                    onToggle: ctrl.toggleLiked,
                    selectedColor: const Color(0xFF1B4332),
                    selectedBorder: const Color(0xFF4CAF50),
                    selectedText: const Color(0xFF4CAF50),
                    unselectedColor: _softPurple, unselectedText: _textSub,
                  )),
                  const SizedBox(height: 20),

                  // Disliked foods
                  _FormLabel('Foods Baby Refuses', Icons.block_rounded, const Color(0xFFEF5350)),
                  const SizedBox(height: 4),
                  const Text('These are filtered out — baby will never see them',
                    style: TextStyle(color: _textSub, fontSize: 11)),
                  const SizedBox(height: 8),
                  Obx(() => IngredientSelector(
                    options: _foodOptions, selectedItems: ctrl.dislikedFoods,
                    onToggle: ctrl.toggleDisliked,
                    selectedColor: const Color(0xFF3B0A0A),
                    selectedBorder: const Color(0xFFEF5350),
                    selectedText: const Color(0xFFEF5350),
                    unselectedColor: _softPurple, unselectedText: _textSub,
                  )),
                  const SizedBox(height: 20),

                  // Cooking methods
                  _FormLabel('Preferred Cooking', Icons.local_fire_department_rounded, _accent),
                  const SizedBox(height: 4),
                  const Text('AI will advise the healthiest method for your baby',
                    style: TextStyle(color: _textSub, fontSize: 11)),
                  const SizedBox(height: 8),
                  Obx(() => IngredientSelector(
                    options: _prepOptions, selectedItems: ctrl.prepMethods,
                    onToggle: ctrl.togglePrepMethod,
                    selectedColor: const Color(0xFF3B2800),
                    selectedBorder: _accent,
                    selectedText: _accent,
                    unselectedColor: _softPurple, unselectedText: _textSub,
                  )),
                  const SizedBox(height: 24),

                  // Generate button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ctrl.isLoading.value ? null : ctrl.generateMealPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: _softPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: ctrl.isLoading.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)),
                                SizedBox(width: 12),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Finding perfect recipe...',
                                      style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('This can take 10–20 seconds',
                                      style: TextStyle(color: Color(0xFFE5E7EB),
                                        fontSize: 11)),
                                  ],
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.explore_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Explore More Meal Ideas',
                                  style: TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                              ],
                            ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Error ────────────────────────────────────────────────
            Obx(() {
              if (ctrl.error.value.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B0A0A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF5350)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                      color: Color(0xFFEF5350), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(ctrl.error.value,
                        style: const TextStyle(color: Colors.white70,
                          fontSize: 13, height: 1.4)),
                    ),
                  ],
                ),
              );
            }),

            // ── Result card ──────────────────────────────────────────
            Obx(() {
              final plan = ctrl.mealPlan.value;
              if (plan == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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


class _FormLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _FormLabel(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold,
            fontSize: 13, letterSpacing: 0.3)),
      ],
    );
  }
}