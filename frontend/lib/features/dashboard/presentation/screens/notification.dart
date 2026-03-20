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

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  static const Map<NotificationType, (IconData, Color, String)> _typeConfig = {
    NotificationType.appointment: (Icons.calendar_today_rounded, GrowWiseColors.accentAppointment, 'Appointment'),
    NotificationType.vitamin: (Icons.medication_liquid_rounded, GrowWiseColors.accentVitamin, 'Supplement'),
    NotificationType.vaccination: (Icons.vaccines_rounded, GrowWiseColors.accentVaccination, 'Vaccination'),
    NotificationType.growth: (Icons.show_chart_rounded, GrowWiseColors.accentGrowth, 'Growth'),
  };

  @override
  Widget build(BuildContext context) {
    final (iconData, accentColor, typeLabel) = _typeConfig[notification.type]!;
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      confirmDismiss: (_) => _confirmDismiss(context),
      background: _buildSwipeBackground(accentColor),
      child: GestureDetector(onTap: onTap, child: _buildCardBody(iconData, accentColor, typeLabel)),
    );
  }

  Widget _buildSwipeBackground(Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red.shade900.withOpacity(0.0), Colors.red.shade700]),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<bool?> _confirmDismiss(BuildContext context) async => true;

  Widget _buildCardBody(IconData iconData, Color accentColor, String typeLabel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [GrowWiseColors.cardGradStart, GrowWiseColors.cardGradEnd]),
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
          top: BorderSide(color: GrowWiseColors.violet.withOpacity(0.25), width: 1),
          right: BorderSide(color: GrowWiseColors.violet.withOpacity(0.1), width: 1),
          bottom: BorderSide(color: GrowWiseColors.violet.withOpacity(0.1), width: 1),
        ),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(0.12), blurRadius: 20, spreadRadius: -2, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconChip(iconData, accentColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeBadge(typeLabel, accentColor),
                      const SizedBox(height: 6),
                      Text(notification.title, style: TextStyle(color: notification.isRead ? GrowWiseColors.textMuted : GrowWiseColors.textPrimary, fontSize: 14, fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w700, height: 1.45)),
                    ],
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(width: 10),
                  Container(width: 9, height: 9, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: accentColor.withOpacity(0.6), blurRadius: 6)])),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: GrowWiseColors.violet.withOpacity(0.2), height: 1, thickness: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Swipe left to dismiss', style: TextStyle(color: GrowWiseColors.textDim.withOpacity(0.6), fontSize: 10, fontStyle: FontStyle.italic)),
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 11, color: GrowWiseColors.amber.withOpacity(0.8)),
                  const SizedBox(width: 4),
                  Text(notification.timestamp, style: TextStyle(color: GrowWiseColors.amber.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconChip(IconData iconData, Color accentColor) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [GrowWiseColors.iconBg, accentColor.withOpacity(0.25)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Center(child: Icon(iconData, color: GrowWiseColors.amberLight, size: 24)),
    );
  }

  Widget _buildTypeBadge(String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: accentColor.withOpacity(0.18), borderRadius: BorderRadius.circular(6)),
      child: Text(label.toUpperCase(), style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
    );
  }
}

class _EmptyState extends StatefulWidget {
  const _EmptyState({super.key});
  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

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
                width: 140, height: 140,
                child: CustomPaint(
                  painter: _RingsPainter(color: GrowWiseColors.primaryPurple, pulseOpacity: pulseOpacity),
                  child: Center(
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(colors: [GrowWiseColors.violet.withOpacity(0.4), GrowWiseColors.iconBg]),
                        shape: BoxShape.circle,
                        border: Border.all(color: GrowWiseColors.violet.withOpacity(0.5), width: 1.5),
                      ),
                      child: Icon(Icons.notifications_off_outlined, size: 30, color: GrowWiseColors.textMuted.withOpacity(0.5 + pulseOpacity * 0.5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("You're all caught up!", style: TextStyle(color: GrowWiseColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('No new notifications right now.\nCheck back later.', textAlign: TextAlign.center, style: TextStyle(color: GrowWiseColors.textMuted.withOpacity(0.7), fontSize: 13, height: 1.6)),
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
      final paint = Paint()..color = color.withOpacity(opacity)..style = PaintingStyle.stroke..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.pulseOpacity != pulseOpacity;
}

class _NavButton extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isActive ? 48 : 40,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? GrowWiseColors.amber.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  isActive ? activeIcon : inactiveIcon,
                  color: isActive ? GrowWiseColors.navIconActive : GrowWiseColors.navIconInactive,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isActive ? GrowWiseColors.navIconActive : GrowWiseColors.navIconInactive,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: GrowWiseColors.amber,
                shape: BoxShape.circle,
                boxShadow: isActive ? [BoxShadow(color: GrowWiseColors.amber.withOpacity(0.6), blurRadius: 6)] : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}