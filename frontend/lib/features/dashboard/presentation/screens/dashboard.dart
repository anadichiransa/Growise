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
           /// ✨ GLOW EFFECTS
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.purple.withOpacity(0.25),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withOpacity(0.15),
              ),
            ),
          ),
          /// 📱 MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// HEADER SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      /// Profile Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.bgLight,
                        backgroundImage: const NetworkImage(
                          'https://i.pravatar.cc/150?img=32',
                        ),
                        onBackgroundImageError: (_, __) {},
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.orange.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Greeting Text
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Good Morning,",
                              style: TextStyle(
                                color: AppColors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Amara Perera",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Notification Icon
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bgLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// MAIN BODY - SCROLLABLE
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// QUICK OVERVIEW CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.bgMid,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.purple.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "QUICK OVERVIEW",
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "Active",
                                          style: TextStyle(
                                            color: AppColors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              /// Child's Name and Status
                              const Text(
                                "Sahan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.emoji_emotions_outlined,
                                      color: AppColors.green,
                                      size: 14,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Doing great!",
                                      style: TextStyle(
                                        color: AppColors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              /// Latest Update
                              const Text(
                                "Latest update:",
                                style: TextStyle(
                                  color: AppColors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.height,
                                      color: AppColors.green,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Height & Weight recorded today",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),


