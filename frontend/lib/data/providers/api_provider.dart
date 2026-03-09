import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/config/api_config.dart';

class ApiProvider {
  final String _authUrl = "${ApiConfig.baseUrl}/auth";

  // Login Method
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$_authUrl/login');

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> register(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': 'New User', // You can add a name controller later
        'email': email,
        'password': password,
        'phone_number': '', // Optional fields for now
        'language_preference': 'English',
      }),
    );
  }
}
