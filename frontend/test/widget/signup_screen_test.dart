import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:growise/features/auth/presentation/controllers/auth_controller.dart';
import 'package:growise/features/auth/presentation/screens/signup_screen.dart';

void main() {
  setUp(() {
    final mockAuth = MockFirebaseAuth();
    Get.put(AuthController.withAuth(mockAuth));
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
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('Three form fields present', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: SignUpScreen()),
      );
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    });

    testWidgets('User can enter email', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: SignUpScreen()),
      );
      await tester.enterText(
          find.byType(TextFormField).first, 'newuser@example.com');
      expect(find.text('newuser@example.com'), findsOneWidget);
    });
  });
}
