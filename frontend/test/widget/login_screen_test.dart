import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:growise/features/auth/presentation/controllers/auth_controller.dart';
import 'package:growise/features/auth/presentation/screens/login_screen.dart';

void main() {
  setUp(() {
    final mockAuth = MockFirebaseAuth();
    Get.put(AuthController.withAuth(mockAuth));
  });

  tearDown(() => Get.reset());

  group('LoginScreen - UI Elements', () {
    testWidgets('Login screen renders without crashing', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: LoginScreen()),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Email field is present', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: LoginScreen()),
      );
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('Login button is present', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: LoginScreen()),
      );
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('Sign up button is present', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: LoginScreen()),
      );
      expect(find.widgetWithText(OutlinedButton, 'Sign up'), findsOneWidget);
    });

    testWidgets('Forgot Password text is present', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: LoginScreen()),
      );
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Welcome Back heading is present', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: LoginScreen()),
      );
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('User can type in email field', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: LoginScreen()),
      );
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}
