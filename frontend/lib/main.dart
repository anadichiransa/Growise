import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/meals/presentation/screens/meal_planner_screen.dart';

void main() {
  runApp(const GrowiseApp());
}

class GrowiseApp extends StatelessWidget {
  const GrowiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Growise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B21B6)),
        useMaterial3: true,
      ),
      // Launch straight into the Meal Bot screen
      home: const MealPlannerScreen(),
    );
  }
}
