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

/// 📝 EDIT PROFILE SCREEN (Placeholder)
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          "Edit Profile Screen",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// 🔑 ACCESS REQUESTS SCREEN (Placeholder)
class AccessRequestsScreen extends StatelessWidget {
  const AccessRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Access Requests"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          "Access Requests Screen",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// 🆘 HELP & RECOVERY SCREEN (Placeholder)
class HelpRecoveryScreen extends StatelessWidget {
  const HelpRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Help & Recovery"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          "Help & Recovery Screen",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// 📞 SUPPORT CENTER SCREEN (Placeholder)
class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Support Center"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          "Support Center Screen",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// ⚙️ SETTINGS SCREEN (UPDATED WITH NAVIGATION)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to dashboard or previous screen
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ACCOUNT MANAGEMENT SECTION
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

            /// Edit Profile Tile with Navigation
            _buildTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),

            const SizedBox(height: 10),

            /// Access Requests Tile with Navigation
            _buildTile(
              icon: Icons.verified_user_outlined,
              title: "Access Requests",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccessRequestsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            /// SUPPORT & SAFETY SECTION
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

            /// Help & Recovery Tile with Navigation
            _buildTile(
              icon: Icons.shield_outlined,
              title: "Help & Recovery",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpRecoveryScreen()),
                );
              },
            ),

            const SizedBox(height: 10),

            /// Support Center Tile with Navigation
            _buildTile(
              icon: Icons.help_outline,
              title: "Support Center",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupportCenterScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            /// 🔥 LOGOUT BUTTON
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
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _showLogoutDialog(context);
                },
              ),
            ),
          ],
        ),
      ),

      /// 🔻 Bottom Navigation Bar with Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bg,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white60,
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0: // Home
              // Navigate to home/dashboard
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Home")));
              break;
            case 1: // Tracker
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Tracker")));
              break;
            case 2: // Education
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Education")));
              break;
            case 3: // Support
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportCenterScreen()),
              );
              break;
            case 4: // Settings
              // Already on settings
              break;
          }
        },
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

  /// 🔹 Tile Widget with onTap functionality
  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        ),
      ),
    );
  }

  /// 🚪 Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
