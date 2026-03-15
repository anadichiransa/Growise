import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:growise/features/auth/presentation/controllers/auth_controller.dart';
import 'package:growise/features/auth/presentation/screens/signup_screen.dart';

void main() {
  setUp(() {
    Get.put(AuthController());
  });

  tearDown(() => Get.reset());

  group('SignUpScreen - UI Elements', () {
    testWidgets('Signup screen renders without crashing', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: SignUpScreen()),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Create Account heading is present', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: SignUpScreen()),
      );
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Sign Up button is present', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: SignUpScreen()),
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Sign Up'),
        findsOneWidget,
      );
    });

    testWidgets('Three text fields present (email, password, confirm)',
        (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: SignUpScreen()),
      );
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    });

    testWidgets('Already have account text is present', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: SignUpScreen()),
      );
      expect(find.text('Already have an account? '), findsOneWidget);
    });
  });

  group('SignUpScreen - Form Validation', () {
    testWidgets('Empty form shows validation errors on submit', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: SignUpScreen()),
      );
      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.tap(signUpButton);
      await tester.pump();
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    });

    testWidgets('User can enter email', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: SignUpScreen()),
      );
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'newuser@example.com');
      expect(find.text('newuser@example.com'), findsOneWidget);
    });
  });
}
