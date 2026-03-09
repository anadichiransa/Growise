import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Controllers to grab the text data
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D1B41),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Sign Up", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Join the Sri Lanka Child Care and Development community",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Email Field
              _buildLabel("Email"),
              _buildTextField(
                controller: _emailController,
                hint: "name@example.com",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@'))
                    return 'Enter a valid email';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Password Field
              _buildLabel("Password"),
              _buildTextField(
                controller: _passwordController,
                hint: "Enter your password",
                isPassword: true,
                obscureText: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (value) {
                  if (value == null || value.length < 6)
                    return 'Password too short';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Confirm Password Field
              _buildLabel("Confirm Password"),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: "Re-type password",
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                validator: (value) {
                  if (value != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC19454),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Center(
                child: Text("OR", style: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(height: 20),

              // Google Sign Up
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(color: Color(0xFFC19454)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                      height: 24,
                    ), // Placeholder for Google Icon
                    const SizedBox(width: 12),
                    const Text(
                      "Sign Up with Google",
                      style: TextStyle(color: Color(0xFFC19454)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              _buildFooterText(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for cleaner code
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF3F2B55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: onToggle,
              )
            : null,
      ),
    );
  }

  Widget _buildFooterText() {
    return Column(
      children: [
        const Text(
          "By signing up, you agree to our Terms of Service and Privacy Policy...",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account? ",
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, // Navigate to Login
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Color(0xFFC19454),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      _authController.signUp(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }
}
