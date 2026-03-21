import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
 
class NotificationController extends GetxController {
  final NotificationRepository _repo;
 
  NotificationController({NotificationRepository? repository})
      : _repo = repository ?? NotificationRepository();
 
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
 
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  bool get hasNotifications => notifications.isNotEmpty;
 
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final loaded = await _repo.getAll();
      notifications.assignAll(loaded);
    } catch (e) {
      notifications.clear();
      debugPrint('NotificationController.load: $e');
    } finally {
      isLoading.value = false;
    }
  }
 
  Future<void> markAsRead(String id) async {
    HapticFeedback.lightImpact();

    notifications.value = notifications.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();

    _repo.markAsRead(id).catchError((e) {
      debugPrint('NotificationController.markAsRead: $e');
    });
  }
 
  Future<void> dismiss(String id) async {
    HapticFeedback.lightImpact();
 
    notifications.removeWhere((n) => n.id == id);
 
    _repo.deleteById(id).catchError((e) {
      debugPrint('NotificationController.dismiss: $e');
    });
  }
 
  Future<void> clearAll() async {
    HapticFeedback.mediumImpact();
    notifications.clear();
    _repo.clearAll().catchError((e) {
      debugPrint('NotificationController.clearAll: $e');
    });
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}