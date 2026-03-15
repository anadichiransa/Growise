import 'package:flutter/material.dart';
import 'package:growise/data/providers/api_provider.dart';

class AuthController {
  final ApiProvider _apiProvider = ApiProvider();

  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await _apiProvider.login({
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        _showMessage(context, "Welcome back, ${data['full_name']}!");
      } else {
        _showMessage(
          context,
          response.data['detail'] ?? 'Login failed',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage(
        context,
        'Connection error. Please check your internet.',
        isError: true,
      );
    }
  }

  void _showMessage(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFB88E4B),
      ),
    );
  }
}
