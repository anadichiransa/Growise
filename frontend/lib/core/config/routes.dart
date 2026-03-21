import 'package:get/get.dart';
import '../../features/dashboard/presentation/screens/notification.dart';
import '../../features/auth/presentation/screens/welcome_page.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot-pw.dart';
import '../../features/dashboard/presentation/screens/dashboard.dart';
import '../../features/dashboard/presentation/screens/support.dart';
import '../../features/dashboard/presentation/screens/activity_page.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/dashboard/presentation/screens/details.dart';
import '../../features/auth/presentation/screens/signup-form.dart';
import '../../features/auth/presentation/screens/access_requesting.dart';
import '../../features/profile/presentation/screens/profile_loader.dart';
import '../../features/growth/presentation/screens/growth_chart_screen.dart';
import '../../features/vaccines/presentation/screens/vaccine_schedule_screen.dart';
import 'package:provider/provider.dart';
import '../../features/vaccines/presentation/controllers/vaccine_controller.dart';
import '../../features/education/presentation/screens/education_hub_screen.dart';
import '../../features/dashboard/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/help_recovery.dart';

class AppRoutes {
  static const welcome = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPw = '/forgot-password';
  static const dashboard = '/dashboard';
  static const support = '/support';
  static const activity = '/activity';
  static const profile = '/profile';
  static const details = '/details';
  static const signupForm = '/signup-form';
  static const accessRequest = '/access-requesting';
  static const growth = '/growth';
  static const vaccines = '/vaccines';
  static const education = '/education';
  static const notification = '/notification';
  static const settings = '/settings';
  static const help = '/help'

  static final pages = [
    GetPage(name: welcome, page: () => const OnboradingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => SignUpScreen()),
    GetPage(name: forgotPw, page: () => const ForgotPasswordPage()),
    GetPage(name: dashboard, page: () => const BabyTrackerHome()),
    GetPage(name: support, page: () => const SupportCenterScreen()),
    GetPage(name: notification, page: () => const NotificationsScreen()),
    GetPage(
      name: activity,
      page: () => ActivityPage(
        title: 'Activities',
        subtitle: 'Fun learning for your baby',
        videoPath: '',
      ),
    ),
    GetPage(name: profile, page: () => const ProfileLoader()),
    GetPage(name: details, page: () => const OnboardingDetailsPage()),
    GetPage(name: signupForm, page: () => const SignupFormScreen()),
    GetPage(name: accessRequest, page: () => const SetupExperienceScreen()),
    GetPage(name: growth, page: () => const GrowthChartScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: education, page: () => const EducationHubScreen()),
    GetPage(name: help, page: () => const HelpRecoveryScreen()),
    GetPage(
      name: vaccines,
      page: () => ChangeNotifierProvider(
        create: (_) => VaccineController(),
        child: const VaccineScheduleScreen(),
      ),
    ),
  ];
}
