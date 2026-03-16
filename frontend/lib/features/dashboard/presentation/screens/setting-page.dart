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
/// ⚙️ SETTINGS SCREEN
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: const Icon(Icons.arrow_back),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ACCOUNT
            const Text(
              "ACCOUNT MANAGEMENT",
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildTile(Icons.person_outline, "Edit Profile"),
            const SizedBox(height: 10),
            _buildTile(Icons.verified_user_outlined, "Access Requests"),

            const SizedBox(height: 35),

            /// SUPPORT
            const Text(
              "SUPPORT & SAFETY",
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildTile(Icons.shield_outlined, "Help & Recovery"),
            const SizedBox(height: 10),
            _buildTile(Icons.help_outline, "Support Center"),

            const Spacer(),
            /// 🔥 LOGOUT BUTTON (WORKING)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Logout",
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _showLogoutDialog(context);
                },
              ),

              /// 🔻 Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bg,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white60,
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Tracker",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Education"),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: "Support",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
            ),
          ],
        ),
      ),



