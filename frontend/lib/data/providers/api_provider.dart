import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// HTTP client for backend API
class ApiProvider {
  late final Dio _dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000/api/v1',  // Change for production
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Add authentication token to all requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _auth.currentUser?.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// Sync child to backend
  Future<bool> syncChild(Map<String, dynamic> childData) async {
    try {
      await _dio.post('/children', data: childData);
      return true;
    } catch (e) {
      print('Backend sync failed (will retry later): $e');
      return false;
    }
  }
}