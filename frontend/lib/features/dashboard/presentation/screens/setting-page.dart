import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// 🎨 App Colors (Extracted from UI)
class AppColors {
  static const bg = Color(0xFF140824);
  static const card = Color(0xFF1E0E34);
  static const cardDark = Color(0xFF2A0D44);
  static const primary = Color(0xFF5A1E63);
  static const accent = Color(0xFFFFB74D);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
      ),

      home: const SettingsScreen(),
    );
  }
}
/// 🔐 LOGIN SCREEN
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          child: const Text("Login"),
        ),
      ),
    );
  }
}

