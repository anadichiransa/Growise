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
  static const Color cardSurface = Color(0xFF2E1A72);
  static const Color tileSurface = Color(0xFF3A2280);
  static const Color tileSurfacePressed = Color(0xFF4A2E9A);
  static const Color communityGradientStart = Color(0xFF4A2A9A);
  static const Color communityGradientEnd = Color(0xFF2E1A72);
  static const Color accent = Color(0xFFFFD600);
  static const Color teal = Color(0xFF00D9C0);
  static const Color tealDim = Color(0x3000D9C0);
  static const Color inputBackground = Color(0xFF3D258A);
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

class _SupportCenterScreenState extends State<SupportCenterScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Animation<double> _stagger(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entranceCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _GrowiseAppBar(),
      body: Stack(
        children: [
          const _BackgroundGlow(),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              children: [
                _FadeSlide(
                  animation: _stagger(0),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Sections coming in next commits…',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FadeSlide({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _GlowPainter()));
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, -0.7),
        radius: 0.9,
        colors: const [Color(0x552A1060), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GrowiseAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: const Text(
        'SUPPORT CENTER',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Colors.transparent],
          ),
        ),
      ),
    );
  }
}
