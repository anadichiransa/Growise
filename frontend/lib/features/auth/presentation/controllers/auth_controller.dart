import "package:flutter/material.dart";
import "package:frontend/data/providers/api_provider.dart";

class AuthController {
  final ApiProvider _apiProvider = ApiProvider();

  //basic skeleton for login logic
  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {}
}
