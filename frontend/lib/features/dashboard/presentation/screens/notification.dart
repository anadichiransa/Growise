import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class GrowWiseColors {
  static const Color scaffoldBg    = Color(0xFF200E36);
  static const Color cardBg        = Color(0xFF4E1D51);
  static const Color iconBg        = Color(0xFF501E51);
  static const Color cardGradStart = Color(0xFF58295B);
  static const Color cardGradEnd   = Color(0xFF381046);
  static const Color amber         = Color(0xFFC88A28);
  static const Color amberLight    = Color(0xFFE0A840);
  static const Color primaryPurple = Color(0xFF5C2868);
  static const Color violet        = Color(0xFF8048AC);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textMuted     = Color(0xFFB8A0C0);
  static const Color textDim       = Color(0xFF786090);
  static const Color navBg             = Color(0xFF1C0A30);
  static const Color navIconActive     = Color(0xFFC88A28);
  static const Color navIconInactive   = Color(0xFF7A7498);
  static const Color accentAppointment = Color(0xFF7C3AED);
  static const Color accentVitamin     = Color(0xFF059669);
  static const Color accentVaccination = Color(0xFFDC2626);
  static const Color accentGrowth      = Color(0xFFC88A28);
}

enum NotificationType { appointment, vitamin, vaccination, growth }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String timestamp;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
      );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const GrowWiseApp());
}

class GrowWiseApp extends StatelessWidget {
  const GrowWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrowWise',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const Scaffold(
        backgroundColor: GrowWiseColors.scaffoldBg,
        body: Center(
          child: Text('GrowWise', style: TextStyle(color: GrowWiseColors.textPrimary)),
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: GrowWiseColors.primaryPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: GrowWiseColors.scaffoldBg,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class _EmptyState extends StatefulWidget {
  const _EmptyState({super.key});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          final pulseOpacity = 0.3 + (_pulseCtrl.value * 0.4);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _RingsPainter(
                    color: GrowWiseColors.primaryPurple,
                    pulseOpacity: pulseOpacity,
                  ),
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            GrowWiseColors.violet.withOpacity(0.4),
                            GrowWiseColors.iconBg,
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GrowWiseColors.violet.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_off_outlined,
                        size: 30,
                        color: GrowWiseColors.textMuted
                            .withOpacity(0.5 + pulseOpacity * 0.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "You're all caught up!",
                style: TextStyle(
                  color: GrowWiseColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No new notifications right now.\nCheck back later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GrowWiseColors.textMuted.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final Color color;
  final double pulseOpacity;

  _RingsPainter({required this.color, required this.pulseOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final radius = 35.0 + i * 15;
      final opacity = (pulseOpacity - i * 0.1).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.pulseOpacity != pulseOpacity;
}