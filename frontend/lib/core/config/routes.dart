import 'package:get/get.dart';
import '../../features/auth/presentation/screens/welcome_page.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot-pw.dart';
import '../../features/dashboard/presentation/screens/dashboard.dart';
import '../../features/dashboard/presentation/screens/support.dart';
import '../../features/dashboard/presentation/screens/activity_page.dart';
import '../../features/growth/presentation/screens/growth_chart_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class AppRoutes {
  // Route name constants
  static const welcome = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPw = '/forgot-password';
  static const dashboard = '/dashboard';
  static const support = '/support';
  static const activity = '/activity';
  static const profile = '/profile';
  static const growth = '/growth';

  static final pages = [
    GetPage(name: welcome, page: () => const OnboradingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: forgotPw, page: () => const ForgotPasswordScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: support, page: () => const SupportScreen()),
    GetPage(name: activity, page: () => const ActivityPage()),
    GetPage(name: profile, page: () => const ProfileScreen()),
  ];
}
