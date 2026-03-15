import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/vaccination.dart';
import '../../../core/constants/api_endpoints.dart';

class VaccineRepository {
  final String baseUrl = ApiEndpoints.baseUrl; // use your existing constant

  Future<List<AgeGroup>> getImmunizationSchedule(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/vaccines/schedule/$childId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['schedule'] as List)
          .map((g) => AgeGroup.fromJson(g))
          .toList();
    }
    throw Exception('Failed to load schedule');
  }

  Future<void> markVaccineDone(
    String childId,
    String vaccineId,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/vaccines/schedule/$childId/$vaccineId/mark-done'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark vaccine done');
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingNotifications(
      String parentUid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/vaccines/upcoming/$parentUid'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['notifications']);
    }
    throw Exception('Failed to load notifications');
  }

  Future<void> generateSchedule(String childId) async {
    await http.post(
      Uri.parse('$baseUrl/vaccines/schedule/$childId/generate'),
    );
  }
}