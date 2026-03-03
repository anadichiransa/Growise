import "package:flutter/material.dart";

class OnboradingScreen extends StatelessWidget {
  const OnboradingScreen({super.key});

  @override
  Widget build(BuildContext) {
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
            const SizedBox(height: 40),
            const Text(
              "GROWISE",
              style: TextStyle(
                color: Color(0xFFE2A673),
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF3B1E54),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.assest("assests/images/icon1.png"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
