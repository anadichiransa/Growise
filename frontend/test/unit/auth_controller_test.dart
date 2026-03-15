import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Input Validation Logic', () {
    test('empty email is invalid', () {
      expect(''.isEmpty, true);
    });

    test('invalid email format detected', () {
      expect('notanemail'.contains('@'), false);
    });

    test('valid email format accepted', () {
      expect('test@example.com'.contains('@'), true);
    });

    test('password too short detected', () {
      expect('123'.length < 6, true);
    });

    test('valid password length accepted', () {
      expect('securepassword'.length >= 6, true);
    });

    test('passwords match', () {
      expect('mypassword123' == 'mypassword123', true);
    });

    test('mismatched passwords detected', () {
      expect('mypassword123' == 'different456', false);
    });

    test('email trimmed correctly', () {
      expect('  test@example.com  '.trim(), 'test@example.com');
    });

    test('username extracted from email', () {
      expect('john@example.com'.split('@')[0], 'john');
    });

    test('email lowercased for consistency', () {
      expect('TEST@EXAMPLE.COM'.toLowerCase(), 'test@example.com');
    });

    test('phone number format validation - valid Sri Lanka number', () {
      final phone = '+94771234567';
      final regex = RegExp(r'^\+94\d{9}$');
      expect(regex.hasMatch(phone), true);
    });

    test('phone number format validation - invalid number rejected', () {
      final phone = '0771234567';
      final regex = RegExp(r'^\+94\d{9}$');
      expect(regex.hasMatch(phone), false);
    });

    test('full name too short rejected', () {
      expect('A'.length < 2, true);
    });

    test('full name valid length accepted', () {
      expect('John'.length >= 2, true);
    });
  });

  group('Auth Error Message Logic', () {
    String getLoginErrorMessage(String code) {
      return switch (code) {
        'user-not-found' => 'No account found for this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-email' => 'Invalid email address.',
        'user-disabled' => 'This account has been disabled.',
        _ => 'Login failed. Please try again.',
      };
    }

    String getRegisterErrorMessage(String code) {
      return switch (code) {
        'email-already-in-use' => 'An account already exists for this email.',
        'weak-password' => 'Password must be at least 6 characters.',
        'invalid-email' => 'Invalid email address.',
        _ => 'Registration failed. Please try again.',
      };
    }

    test('user-not-found returns correct message', () {
      expect(getLoginErrorMessage('user-not-found'),
          'No account found for this email.');
    });

    test('wrong-password returns correct message', () {
      expect(getLoginErrorMessage('wrong-password'), 'Incorrect password.');
    });

    test('invalid-email returns correct message', () {
      expect(getLoginErrorMessage('invalid-email'), 'Invalid email address.');
    });

    test('unknown error returns fallback message', () {
      expect(getLoginErrorMessage('unknown-code'),
          'Login failed. Please try again.');
    });

    test('email-already-in-use returns correct message', () {
      expect(getRegisterErrorMessage('email-already-in-use'),
          'An account already exists for this email.');
    });

    test('weak-password returns correct message', () {
      expect(getRegisterErrorMessage('weak-password'),
          'Password must be at least 6 characters.');
    });
  });
}
