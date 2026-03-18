import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// 🎨 COLORS
class AppColors {
  static const bgDark = Color(0xFF140824);
  static const bgMid = Color(0xFF1E0E34);
  static const bgLight = Color(0xFF2A1245);

  static const purple = Color(0xFF6D4C9C);
  static const green = Color(0xFF26D07C);
  static const orange = Color(0xFFF6A960);

  static const white = Colors.white;
  static const white60 = Colors.white60;
  static const white70 = Colors.white70;
  static const white54 = Colors.white54;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const BabyTrackerHome(),
    );
  }
}

class BabyTrackerHome extends StatelessWidget {
  const BabyTrackerHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// 🌈 BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
