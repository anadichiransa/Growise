import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/immunization_record.dart';

class ImmunizationService {
  static const String baseUrl = 'https://your-api-url.com'; // Replace with your URL

  Future<List<AgeGroup>> getSchedule(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/immunization-schedule'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['schedule'] as List)
          .map((g) => AgeGroup.fromJson(g))
          .toList();
    }
    throw Exception('Failed to load schedule: ${response.statusCode}');
  }

  Future<void> markDone(
    String childId,
    String vaccineId,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/children/$childId/immunization/$vaccineId/mark-done'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark done: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications(String parentUid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/upcoming-vaccines/$parentUid'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['notifications']);
    }
    throw Exception('Failed to load notifications');
  }
}