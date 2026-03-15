import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;
  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save profile to backend (non-blocking — don't fail signup if this fails)
      try {
        await ApiProvider().saveUserProfile({
          'uid': credential.user!.uid,
          'full_name':
              email.split('@')[0], // temporary until we have name field
          'email': email.trim(),
          'phone_number': '+94000000000', // temporary placeholder
          'language_preference': 'English',
        });
      } catch (e) {
        // Silent — user is still registered in Firebase Auth
      }

      Get.offAllNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      // ... existing error handling
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
