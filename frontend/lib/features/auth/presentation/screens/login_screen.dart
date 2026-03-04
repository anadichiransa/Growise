import "package:flutter/material.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color PrimaryBg = Color(0xFF1E0E35);
  static const Color accentGold = Color(0xFFB88E4B);
  static const Color fieldBg = Color(0xFF33244D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}
