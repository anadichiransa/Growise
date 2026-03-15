import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'features/growth/screens/growth_chart_screen.dart';

void main() {
  runApp(const GrowIseApp());
}

class GrowIseApp extends StatelessWidget {
  const GrowIseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrowIse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColours.background,
        colorScheme: ColorScheme.dark(
          primary: AppColours.primaryGold,
          surface: AppColours.deepMagenta,
        ),
        fontFamily: 'Roboto',
      ),
      // ── For testing: opens directly to growth chart ──
      // In your real app, replace this with your actual home/navigation screen
      home: const GrowthChartScreen(
        childId:     'test-child-001',
        childName:   'Baby',
        gender:      'male',
        dateOfBirth: DateTime(2023, 8, 5),  // change to real DOB
      ),
    );
  }
}