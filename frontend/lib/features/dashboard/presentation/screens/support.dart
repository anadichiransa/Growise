import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const GrowiseApp());
}

class GrowiseApp extends StatelessWidget {
  const GrowiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.cardSurface,
        ),
      ),
      home: const SupportCenterScreen(),
    );
  }
}

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF160D38);
  static const Color backgroundGlow = Color(0xFF2A1060);
  static const Color cardSurface = Color.fromARGB(255, 90, 17, 109);
  static const Color tileSurface = Color(0xFF3A2280);
  static const Color tileSurfacePressed = Color.fromARGB(255, 90, 17, 109);
  static const Color communityGradientStart = Color.fromARGB(255, 90, 17, 109);
  static const Color communityGradientEnd = Color.fromARGB(255, 90, 17, 109);
  static const Color accent = Color(0xFFFFD600);
  static const Color teal = Color(0xFF00D9C0);
  static const Color tealDim = Color(0x3000D9C0);
  static const Color inputBackground = Color.fromARGB(255, 90, 17, 109);
  static const Color inputBorderFocused = Color(0xFF00D9C0);
  static const Color shimmerBase = Color(0xFF2E1A72);
  static const Color shimmerHighlight = Color(0xFF4A30A0);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8A8E0);
  static const Color sectionLabel = Color(0xFFD0C0F0);
  static const Color navBackground = Color(0xFF1A0F4A);
  static const Color navPill = Color(0xFF3A2280);
}

class FaqItem {
  final IconData icon;
  final String title;
  final String answer;

  const FaqItem({
    required this.icon,
    required this.title,
    required this.answer,
  });
}

const List<FaqItem> _allFaqs = [
  FaqItem(
    icon: Icons.vaccines_outlined,
    title: 'Vaccination records',
    answer:
        'Go to your child\'s profile → tap "Health Records" → select '
        '"Vaccinations". All administered and upcoming vaccines are listed '
        'there with dates and the clinic name.',
  ),
  FaqItem(
    icon: Icons.lock_reset_outlined,
    title: 'Reset password',
    answer:
        'On the login screen tap "Forgot password?". Enter your registered '
        'email address and we\'ll send you a reset link within 2 minutes. '
        'Check your spam folder if you don\'t see it.',
  ),
  FaqItem(
    icon: Icons.visibility_off_outlined,
    title: 'Privacy settings',
    answer:
        'Open Settings → Privacy. You can control who can see your child\'s '
        'profile, opt out of anonymised data sharing, and download or delete '
        'all your data at any time (PDPA Art. 14).',
  ),
  FaqItem(
    icon: Icons.monitor_weight_outlined,
    title: 'Growth chart not updating',
    answer:
        'Growth charts refresh after you log a new weight or height entry. '
        'Make sure you are connected to the internet at least once so your '
        'local entries sync to the cloud.',
  ),
  FaqItem(
    icon: Icons.notifications_outlined,
    title: 'Turning off reminders',
    answer:
        'Go to Settings → Notifications and toggle off the reminder types you '
        'no longer need. Changes take effect immediately.',
  ),
];

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text(
          'Support Center\n— building in progress —',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}