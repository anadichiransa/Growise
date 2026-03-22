import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';

class ApiProvider {
  final Dio _dio;

  ApiProvider()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: Duration(milliseconds: ApiConfig.timeoutMs),
            receiveTimeout: Duration(milliseconds: ApiConfig.timeoutMs),
            sendTimeout: Duration(milliseconds: ApiConfig.timeoutMs),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  // ── Auth ──────────────────────────────────────────────
  Future<Response> login(Map<String, dynamic> data) async {
    return await _dio.post('/auth/login', data: data);
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/auth/register', data: data);
  }

  Future<bool> syncChild(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/children', data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Response> saveUserProfile(Map<String, dynamic> data) async {
    return await _dio.post('/auth/profile', data: data);
  }

  // ── Growth ────────────────────────────────────────────
  Future<Response> syncGrowthRecord(Map<String, dynamic> data) async {
    return await _dio.post('/growth/records', data: data);
  }

  Future<Response> getGrowthRecords(String childId) async {
    return await _dio.get('/growth/records/$childId');
  }

  // ── Children ──────────────────────────────────────────
  Future<Response> createChild(Map<String, dynamic> data) async {
    return await _dio.post('/children', data: data);
  }

  Future<Response> getChildren() async {
    return await _dio.get('/children');
  }

  // ── Meals ─────────────────────────────────────────────
  Future<Response> generateMealPlan(Map<String, dynamic> data) async {
    return await _dio.post('/meals/generate', data: data);
  }

  // ── Vaccines ──────────────────────────────────────────
  Future<Response> getVaccineSchedule(String childId) async {
    return await _dio.get('/vaccines/schedule/$childId');
  }

  // ── Helper ────────────────────────────────────────────
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}