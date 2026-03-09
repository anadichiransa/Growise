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
      } else {
        final errorData = jsonDecode(response.body);
      }
    } catch (e) {}
  }
}
