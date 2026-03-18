import 'package:get/get.dart';
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

  static final pages = [
    GetPage(name: welcome, page: () => const OnboradingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => SignUpScreen()),
    GetPage(name: forgotPw, page: () => const ForgotPasswordPage()),
    GetPage(name: dashboard, page: () => const BabyTrackerHome()),
    GetPage(name: support, page: () => const SupportCenterScreen()),
    GetPage(
        name: activity,
        page: () => ActivityPage(
              title: 'Activities',
              subtitle: 'Fun learning for your baby',
              videoPath: '',
            )),
    GetPage(name: profile, page: () => const ProfileLoader()),
    GetPage(name: details, page: () => const OnboardingDetailsPage()),
    GetPage(name: signupForm, page: () => const SignupFormScreen()),
    GetPage(name: accessRequest, page: () => const SetupExperienceScreen()),
  ];
}
