import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:growise/features/auth/presentation/screens/welcome_page.dart';

void main() {
  group('WelcomePage - UI Elements', () {
    testWidgets('Welcome page renders without crashing', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: OnboradingScreen()),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Growise brand name is displayed', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: OnboradingScreen()),
      );
      expect(find.text('GROWISE'), findsOneWidget);
    });

    testWidgets('Get Started button is present', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: OnboradingScreen()),
      );
      expect(find.text('Get Started →'), findsOneWidget);
    });

    testWidgets('Nurturing The Future text is present', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: OnboradingScreen()),
      );
      expect(find.textContaining('Nurturing'), findsOneWidget);
    });

    testWidgets('Login link is present', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: OnboradingScreen()),
      );
      expect(find.text('Existing user? Log in'), findsOneWidget);
    });
  });
}
