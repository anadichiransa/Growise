import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:growise/core/config/routes.dart'; // Handles password reset logic

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Sends a password reset email using Firebase Auth
  Future<void> _sendResetLink() async {
    // 1. Validate the email format locally before calling Firebase
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Call Firebase to send the reset link
      // Uses .trim() to ensure accidental spaces don't cause errors
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // 3. Success Feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent! Check your email.'),
            backgroundColor: Color(0xFF4CAF50), // Green for success
            duration: Duration(seconds: 4),
          ),
        );

        // 4. Auto-navigate back to Login after a short delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Get.offNamed(AppRoutes.login);
        }
      }
    } on FirebaseAuthException catch (e) {
      // 5. Handle specific Firebase error codes for better UX
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // 6. Generic catch for network or unexpected errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unexpected error. Please check your internet connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 7. Ensure loading spinner is hidden regardless of outcome
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B1F3D), // Growise Dark Theme
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(height: 50),
                
                // Icon Header
                Center(
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF463554).withOpacity(0.6),
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFD4956F),
                        child: Icon(Icons.lock_reset, color: Color(0xFF2B1F3D), size: 28),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Don\'t worry it happens. Please enter the email address associated with your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFA89BB5), height: 1.6),
                ),
                
                const SizedBox(height: 36),
                
                // Email Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: const TextStyle(color: Color(0xFF6B5A7E)),
                          filled: true,
                          fillColor: const Color(0xFF3A2D4A),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6B5A7E)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4956F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Color(0xFF2B1F3D))
                              : const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}