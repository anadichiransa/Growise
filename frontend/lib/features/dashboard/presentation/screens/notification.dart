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