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
      // ─────────────────────────────────────────────────────────────────────
      // ⚠️  DEVELOPMENT / TEST MODE  (Bug #4)
      // This screen is hardcoded for local development only.
      // Before release, replace `home:` with your real authentication /
      // onboarding navigator (e.g. AuthGate or a SplashScreen that reads
      // the logged-in user and their child profile from Firestore).
      //
      // Replace the values below with real child data from your auth flow:
      //   childId     → from Firestore child document ID
      //   childName   → from user profile
      //   gender      → from child profile ('male' or 'female')
      //   dateOfBirth → from child profile
      // ─────────────────────────────────────────────────────────────────────
      home: GrowthChartScreen(
        childId:     'test-child-001',
        childName:   'Baby',
        gender:      'male',
        dateOfBirth: DateTime.utc(2023, 8, 5), // ← change to real DOB
      ),
    );
  }
}