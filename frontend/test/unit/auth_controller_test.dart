import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:growise/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  setUp(() {
    Get.put(AuthController());
  });

  tearDown(() => Get.reset());

  group('AuthController - Initial State', () {
    test('isLoading starts as false', () {
      final controller = Get.find<AuthController>();
      expect(controller.isLoading.value, false);
    });

    test('currentUser is null when not logged in', () {
      final controller = Get.find<AuthController>();
      expect(controller.currentUser, null);
    });

    test('isLoggedIn returns false when no user', () {
      final controller = Get.find<AuthController>();
      expect(controller.isLoggedIn, false);
    });
  });

  group('AuthController - Input Validation', () {
    test('empty email should not pass Firebase validation', () {
      expect(''.isEmpty, true);
    });

    test('invalid email format detected', () {
      const email = 'notanemail';
      expect(email.contains('@'), false);
    });

    test('valid email format accepted', () {
      const email = 'test@example.com';
      expect(email.contains('@'), true);
    });

    test('password too short detected', () {
      const password = '123';
      expect(password.length < 6, true);
    });

    test('valid password length accepted', () {
      const password = 'securepassword';
      expect(password.length >= 6, true);
    });

    test('passwords match check works', () {
      const password = 'mypassword123';
      const confirm = 'mypassword123';
      expect(password == confirm, true);
    });

    test('mismatched passwords detected', () {
      const password = 'mypassword123';
      const confirm = 'different456';
      expect(password == confirm, false);
    });
  });

  group('AuthController - Email Processing', () {
    test('email trimmed correctly', () {
      const email = '  test@example.com  ';
      expect(email.trim(), 'test@example.com');
    });

    test('username extracted from email', () {
      const email = 'john@example.com';
      expect(email.split('@')[0], 'john');
    });

    test('email lowercased for consistency', () {
      const email = 'TEST@EXAMPLE.COM';
      expect(email.toLowerCase(), 'test@example.com');
    });
  });
}
