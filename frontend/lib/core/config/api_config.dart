/// API configuration for the Growise backend.
///
/// Change baseUrl depending on your development setup:
///   Android emulator:  http://10.0.2.2:8000/api/v1
///   iOS simulator:     http://localhost:8000/api/v1
///   Physical device:   http://YOUR_LAN_IP:8000/api/v1  (e.g. 192.168.1.42)
///   Production:        https://api.growise.app/api/v1
class ApiConfig {
  // ── Active URL — change this for your setup ─────────────────────
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // ── Alternative URLs (comment/uncomment as needed) ────────────────
  // static const String baseUrl = 'http://localhost:8000/api/v1';       // iOS simulator
  // static const String baseUrl = 'http://192.168.1.42:8000/api/v1';   // physical device

  /// Request timeout in milliseconds.
  /// Groq AI responses take 10-20 seconds — 30 seconds is a safe timeout.
  static const int timeoutMs = 30000;
}
