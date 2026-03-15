import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/who_standard_model.dart';

class ApiService {
  // Android emulator → Mac localhost
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ── WHO Standards ──────────────────────────────────────────────────────────

  /// Fetch all WHO standards for boys in one request.
  /// Returns weight, height and BMI datasets together.
  static Future<WHOStandardsData> getWHOStandardsBoys() async {
    final response = await http.get(
      Uri.parse('$baseUrl/who/all/boys'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return WHOStandardsData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load WHO standards: ${response.body}');
    }
  }

  // ── Growth Tracker ─────────────────────────────────────────────────────────

  static Future<List<dynamic>> getGrowthRecords(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/growth/records?child_id=$childId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['records'];
    }
    throw Exception('Failed to load records: ${response.body}');
  }

  static Future<Map<String, dynamic>> addMeasurement({
    required String childId,
    required String gender,
    required String dateOfBirth,
    required String date,
    required double weight,
    required double height,
    String measuredAt = 'home',
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/growth/records'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'child_id':      childId,
        'gender':        gender,
        'date_of_birth': dateOfBirth,
        'date':          date,
        'weight':        weight,
        'height':        height,
        'measured_at':   measuredAt,
        'notes':         notes,
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Failed to add measurement: ${response.body}');
  }

  static Future<Map<String, dynamic>> updateMeasurement({
    required String recordId,
    required String childId,
    required String gender,
    required String dateOfBirth,
    required String date,
    required double weight,
    required double height,
    String measuredAt = 'home',
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/growth/records/$recordId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'record_id':     recordId,
        'child_id':      childId,
        'gender':        gender,
        'date_of_birth': dateOfBirth,
        'date':          date,
        'weight':        weight,
        'height':        height,
        'measured_at':   measuredAt,
        'notes':         notes,
      }),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to update measurement: ${response.body}');
  }

  static Future<void> deleteMeasurement(String recordId) async {
    final response = await http.delete(
        Uri.parse('$baseUrl/growth/records/$recordId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete: ${response.body}');
    }
  }

  // ── Help & Recovery ────────────────────────────────────────────────────────

  static Future<List<dynamic>> getHelpItems({String search = ''}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/help/items?search=$search'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['items'];
    throw Exception('Failed to load help items: ${response.body}');
  }

  static Future<Map<String, dynamic>> submitSupportTicket({
    required String email,
    required String subject,
    required String message,
    String? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/help/contact'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email':   email,
        'subject': subject,
        'message': message,
        'user_id': userId,
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Failed to submit ticket: ${response.body}');
  }

  // ── Play & Learn ───────────────────────────────────────────────────────────

  static Future<List<dynamic>> getActivities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/learn/activities'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['activities'];
    }
    throw Exception('Failed to load activities: ${response.body}');
  }
}