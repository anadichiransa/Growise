import "package:flutter/material.dart";
import 'package:get/get.dart';

class OnboradingScreen extends StatelessWidget {
  const OnboradingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF210F37),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B1E54).withOpacity(0.5),
                ),
                child: Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4A2574),
                    ),
                    child: const Icon(
                      Icons.face_retouching_natural,
                      size: 55,
                      color: Color(0xFFE2A673),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),

            // 2. GROWISE Tag
            const Text(
              "GROWISE",
              style: TextStyle(
                color: Color(0xFFE2A673),
                letterSpacing: 2,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // 1. Main Title with Split Colors
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Nurturing\n",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  TextSpan(
                    text: "The Future",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2A673),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Description Text
            Text(
              "Your digital companion for tracking\ndevelopment, health, and happiness\nfor every child.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),

            // 5. Get Started Button
            GestureDetector(
              onTap: () => Get.toNamed('/login'),
              child: Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFFBD8E52),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Get Started",
                      style: TextStyle(
                        color: Color(0xFF210F37),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Color(0xFF210F37)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // 6. Login Link
            GestureDetector(
              onTap: () => Get.toNamed('/login'),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                  children: [
                    const TextSpan(text: "Existing user? "),
                    TextSpan(
                      text: "Log In",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
