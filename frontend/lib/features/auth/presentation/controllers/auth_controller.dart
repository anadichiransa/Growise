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
