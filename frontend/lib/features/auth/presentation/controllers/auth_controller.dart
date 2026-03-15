import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growise/data/providers/api_provider.dart';

class AuthController extends GetxController {
  late final FirebaseAuth _authInstance;
  FirebaseAuth get _auth => _authInstance;
  var isLoading = false.obs;

  AuthController() {
    _authInstance = FirebaseAuth.instance;
  }

  AuthController.withAuth(FirebaseAuth auth) {
    _authInstance = auth;
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      Get.offAllNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'user-not-found' => 'No account found for this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-email' => 'Invalid email address.',
        'user-disabled' => 'This account has been disabled.',
        _ => 'Login failed. Please try again.',
      };
      Get.snackbar(
        'Login Failed',
        message,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      try {
        await ApiProvider().saveUserProfile({
          'uid': credential.user!.uid,
          'full_name': email.split('@')[0],
          'email': email.trim(),
          'phone_number': '+94000000000',
          'language_preference': 'English',
        });
      } catch (e) {
        // Silent — user still registered in Firebase Auth
      }

      Get.offAllNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'email-already-in-use' => 'An account already exists for this email.',
        'weak-password' => 'Password must be at least 6 characters.',
        'invalid-email' => 'Invalid email address.',
        _ => 'Registration failed. Please try again.',
      };
      Get.snackbar(
        'Signup Failed',
        message,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed('/');
  }

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
}
