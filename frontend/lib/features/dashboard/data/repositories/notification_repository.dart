import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
 
class NotificationRepository {
  static const String _key = 'growise_notifications_v2';
  Future<List<NotificationModel>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr == null || jsonStr.isEmpty) return [];
 
      final List<dynamic> raw = jsonDecode(jsonStr);

      return raw
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('NotificationRepository.getAll error: $e');
      return []; 
    }
  }
 
  Future<void> save(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getAll();
 
      if (existing.any((n) => n.id == notification.id)) return;
 
      existing.insert(0, notification);
 
      await prefs.setString(
        _key,
        jsonEncode(existing.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('NotificationRepository.save error: $e');
    }
  }
 
  Future<void> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getAll();
 
      final updated = existing.map((n) {
        return n.id == id ? n.copyWith(isRead: true) : n;
      }).toList();
 
      await prefs.setString(
        _key,
        jsonEncode(updated.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('NotificationRepository.markAsRead error: $e');
    }
  }
 
  Future<void> deleteById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getAll();
      final updated = existing.where((n) => n.id != id).toList();
      await prefs.setString(
        _key,
        jsonEncode(updated.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('NotificationRepository.deleteById error: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('NotificationRepository.clearAll error: $e');
    }
  }

  Future<bool> exists(String id) async {
    final all = await getAll();
    return all.any((n) => n.id == id);
  }
}