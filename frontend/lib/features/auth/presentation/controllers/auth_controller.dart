import "package:flutter/material.dart";
import "package:frontend/data/providers/api_provider.dart";
import "dart:convert";

class AuthController {
  final ApiProvider _apiProvider = ApiProvider();

  //basic skeleton for login logic
  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await _apiProvider.login(email, password);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showMessage(context, "Welcome back, ${data['full_name']}!");
      } else {
        final errorData = jsonDecode(response.body);
        _showMessage(
          context,
          errorData["detail"] ?? "Login failed",
          isError: true,
        );
      }
    } catch (e) {
      _showMessage(
        context,
        "Connection erro. Please check your internet",
        isError: true,
      );
    }
  }

  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // Create the Map here to send all required fields
      final Map<String, dynamic> userData = {
        'full_name': 'New User',
        'email': email,
        'password': password,
        'phone_number': '0000000000',
        'language_preference': 'English',
      };

      final response = await _apiProvider.register(userData);

      if (response.statusCode == 201) {
        _showMessage(context, "Registration Successful! Please Login.");
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(response.body);
        _showMessage(
          context,
          errorData['detail'] ?? "Registration failed",
          isError: true,
        );
      }
    } catch (e) {
      _showMessage(context, "Server connection failed", isError: true);
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFB88E4B),
      ),
    );
  }
}
