import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/who_standard_model.dart';

class ApiService {
  // Android emulator → Mac localhost
  // Change to your Mac IP if using a real phone e.g. 'http://192.168.1.5:8000'
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ── WHO Standards ──────────────────────────────────────────────────────────

  /// Fetch all WHO standards for boys in one call
  static Future<WHOStandardsData> getWHOStandardsBoys() async {
    final response = await http.get(
      Uri.parse('$baseUrl/who/all/boys'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return WHOStandardsData.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load WHO standards: ${response.body}');
  }

  // ── Growth Records ─────────────────────────────────────────────────────────

  /// Get all growth records for a child
  static Future<List<dynamic>> getGrowthRecords(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/growth/records?child_id=$childId'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['records'];
    }
    throw Exception('Failed to load records: ${response.body}');
  }

  /// Add a new measurement
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
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Failed to add measurement: ${response.body}');
  }

  /// Update an existing measurement
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
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to update: ${response.body}');
  }

  /// Delete a measurement
  static Future<void> deleteMeasurement(String recordId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/growth/records/$recordId'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete: ${response.body}');
    }
  }
}