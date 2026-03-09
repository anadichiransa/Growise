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

  // Register Method ()
  Future<http.Response> register(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_authUrl/register');

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }
}
