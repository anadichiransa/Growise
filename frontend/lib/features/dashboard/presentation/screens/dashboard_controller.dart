// frontend/lib/features/dashboard/presentation/controllers/dashboard_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/use_cases/get_dashboard_data.dart';

class DashboardController extends GetxController {
  static const String _base = 'http://10.0.2.2:8000/api/v1';
  // iOS simulator  → http://127.0.0.1:8000/api/v1
  // Real device    → http://YOUR_PC_IP:8000/api/v1

  final GetDashboardData _getDashboardData;

  DashboardController({GetDashboardData? getDashboardData})
      : _getDashboardData = getDashboardData ?? GetDashboardData();

  // ── Observables ────────────────────────────────────────────────────────────
  final userName     = 'Loading...'.obs;   // ← dynamic from profile API
  final userAvatar   = ''.obs;             // ← avatar_url from profile (empty = use asset)
  final childName    = ''.obs;
  final latestUpdate = ''.obs;
  final nextVaccine  = ''.obs;
  final isLoading    = true.obs;
  final isOnline     = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
    _watchConnectivity();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    // Load both in parallel
    await Future.wait([_fetchUserProfile(), _fetchDashboardData()]);
    isLoading.value = false;
  }

  // ── Fetch display_name + avatar from /profile/me ───────────────────────────
  Future<void> _fetchUserProfile() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        // Fallback: use Firebase Auth displayName directly
        userName.value =
            FirebaseAuth.instance.currentUser?.displayName ?? 'Welcome';
        return;
      }

      final res = await http.get(
        Uri.parse('$_base/profile/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        userName.value   = data['display_name'] ?? data['email'] ?? 'Welcome';
        userAvatar.value = data['avatar_url']   ?? '';
      } else {
        // Graceful fallback
        userName.value =
            FirebaseAuth.instance.currentUser?.displayName ?? 'Welcome';
      }
    } catch (_) {
      userName.value =
          FirebaseAuth.instance.currentUser?.displayName ?? 'Welcome';
    }
  }

  // ── Fetch child + growth data ──────────────────────────────────────────────
  Future<void> _fetchDashboardData() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) return;

      final res = await http.get(
        Uri.parse('$_base/dashboard/summary'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        childName.value    = data['child_name']    ?? 'Your child';
        latestUpdate.value = data['latest_update'] ?? 'No records yet';
        nextVaccine.value  = data['next_vaccine']  ?? 'Not scheduled';
      } else {
        // Fallback to direct Firestore use case
        final fallback = await _getDashboardData();
        childName.value    = fallback.childName;
        latestUpdate.value = fallback.latestUpdate;
        nextVaccine.value  = fallback.nextVaccine;
      }
    } catch (_) {
      final fallback = await _getDashboardData();
      childName.value    = fallback.childName;
      latestUpdate.value = fallback.latestUpdate;
      nextVaccine.value  = fallback.nextVaccine;
    }
  }

  void _watchConnectivity() {
    isOnline.value = true;
  }

  Future<void> refresh() => _loadAll();

  void goToGrowth()      => Get.toNamed('/growth');
  void goToVaccination() => Get.toNamed('/vaccination');
  void goToMeals()       => Get.toNamed('/meals');
  void goToEducation()   => Get.toNamed('/education');
}
