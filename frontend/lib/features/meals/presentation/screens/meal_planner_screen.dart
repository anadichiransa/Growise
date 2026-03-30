import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meal_controller.dart';
import '../widgets/ingredient_selector.dart';
import '../widgets/recipe_card.dart';
import 'package:growise/shared/widgets/common/bottom_nav.dart';
import 'package:growise/core/config/routes.dart';

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  static const _bg = Color(0xFF1A0A2E);
  static const _card = Color(0xFF2D1B4E);
  static const _accent = Color(0xFFD4A017);
  static const _purple = Color(0xFF7C3AED);
  static const _soft = Color(0xFF3D2069);
  static const _textSub = Color(0xFFB39DDB);
  static const _green = Color(0xFF4CAF50);
  static const _red = Color(0xFFEF5350);

  static const _foodOptions = [
    'Rice',
    'Chicken',
    'Dhal',
    'Carrot',
    'Banana',
    'Sweet Potato',
    'Pumpkin',
    'Fish',
    'Egg',
    'Avocado',
    'Papaya',
    'Gotukola',
    'Breadfruit',
  ];

  static const _prepOptions = [
    'Boiled',
    'Steamed',
    'Mashed',
    'Pureed',
    'Baked',
    'Fried',
  ];

  @override
  Widget build(BuildContext context) {
    final MealController ctrl = Get.put(MealController());

    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.offNamed(AppRoutes.dashboard);
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'ONLINE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: _soft,
              child: const Icon(
                Icons.person,
                color: _textSub,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: _soft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history,
                        color: _textSub,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _purple.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 6,
                            ),
                          ],
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4C1D95),
                              Color(0xFF7C3AED),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: _accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Hello, I'm your",
                    style: TextStyle(
                      color: _textSub,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Nutrition Guide!',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tailoring health advice for Sri Lankan child\n'
                    'development with data-driven precision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textSub,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DAILY SUGGESTION',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _soft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'For Age: ${ctrl.childAge.value} Months+',
                              style: const TextStyle(
                                color: _textSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Obx(
                      () => SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _accent,
                          inactiveTrackColor: _soft,
                          thumbColor: _accent,
                          overlayColor: _accent.withOpacity(0.2),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: ctrl.childAge.value.toDouble(),
                          min: 6,
                          max: 24,
                          divisions: 18,
                          label: '${ctrl.childAge.value} months',
                          onChanged: (v) {
                            ctrl.childAge.value = v.round();
                          },
                        ),
                      ),
                    ),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '6 months',
                          style: TextStyle(
                            color: _textSub,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '24 months',
                          style: TextStyle(
                            color: _textSub,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const _Label(
                      'Foods Baby Likes',
                      Icons.favorite_rounded,
                      _green,
                    ),
                    const SizedBox(height: 8),

                    Obx(
                      () => IngredientSelector(
                        options: _foodOptions,
                        selectedItems: ctrl.likedFoods.toList(),
                        onToggle: ctrl.toggleLiked,
                        selectedColor: const Color(0xFF1B4332),
                        selectedBorder: _green,
                        selectedText: _green,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const _Label(
                      'Foods Baby Refuses',
                      Icons.block_rounded,
                      _red,
                    ),
                    const SizedBox(height: 4),

                    const Text(
                      'These are filtered out — baby will never see them',
                      style: TextStyle(
                        color: _textSub,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Obx(
                      () => IngredientSelector(
                        options: _foodOptions,
                        selectedItems: ctrl.dislikedFoods.toList(),
                        onToggle: ctrl.toggleDisliked,
                        selectedColor: const Color(0xFF3B0A0A),
                        selectedBorder: _red,
                        selectedText: _red,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const _Label(
                      'Preferred Cooking',
                      Icons.local_fire_department,
                      _accent,
                    ),
                    const SizedBox(height: 8),

                    Obx(
                      () => IngredientSelector(
                        options: _prepOptions,
                        selectedItems: ctrl.prepMethods.toList(),
                        onToggle: ctrl.togglePrepMethod,
                        selectedColor: const Color(0xFF3B2800),
                        selectedBorder: _accent,
                        selectedText: _accent,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: ctrl.isLoading.value
                              ? null
                              : () async {
                                  await ctrl.generateMealPlan();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: ctrl.isLoading.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Explore More Meal Ideas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Obx(() {
                      if (ctrl.error.value.isNotEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B0A0A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _red),
                          ),
                          child: Text(
                            ctrl.error.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        );
                      }

                      if (ctrl.mealPlan.value != null) {
                        return RecipeCard(mealPlan: ctrl.mealPlan.value!);
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _soft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Choose the baby preferences and press "Explore More Meal Ideas" to generate a meal plan.',
                          style: TextStyle(
                            color: _textSub,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Label(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}