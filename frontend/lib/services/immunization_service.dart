import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/vaccination.dart';

class ImmunizationService {
  static const String baseUrl = 'https://your-api-url.com';

  Future<List<AgeGroup>> getSchedule(String childId) async {
    final response = await http.get(
      Uri.parse('/children//immunization-schedule'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['schedule'] as List)
          .map((g) => AgeGroup.fromJson(g))
          .toList();
    }
    throw Exception('Failed to load schedule: ');
  }

  Future<void> markDone(
    String childId,
    String vaccineId,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('/children//immunization//mark-done'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark done: ');
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications(String parentUid) async {
    final response = await http.get(
      Uri.parse('/notifications/upcoming-vaccines/'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['notifications']);
    }
    throw Exception('Failed to load notifications');
  }
}
