import "package:flutter/material.dart";

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
            const SizedBox(height: 10),
            const Text(
              "Nurturing\nThe Future",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 45),
            const Text(
              "GROWISE",
              style: TextStyle(
                color: Color(0xFFE2A673),
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Your digital companion for tracking development, health, and hapiness for every child",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: () {
                //navigation logic
              },
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2A673),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    "Get Started →",
                    style: const TextStyle(
                      color: Color(0xFF130B2B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Existing user? Log in",
              style: TextStyle(color: Colors.white54),
            ),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF3B1E54),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: const Icon(Icons.child_care,
                      size: 60, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
