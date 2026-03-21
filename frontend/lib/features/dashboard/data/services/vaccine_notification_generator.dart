import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
 
class VaccineEntry {
  final String id;         
  final String name;       
  final DateTime dueDate;  
  final bool isOverdue;    
  final bool isDone;       
 
  const VaccineEntry({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.isOverdue,
    required this.isDone,
  });
}
 
class VaccineNotificationGenerator {
  final NotificationRepository _repo;
 
  VaccineNotificationGenerator({NotificationRepository? repository})
      : _repo = repository ?? NotificationRepository();
 
  Future<void> generateFromSchedule({
    required String childName,
    required List<VaccineEntry> vaccines,
  }) async {
    for (final vaccine in vaccines) {
      if (vaccine.isDone) continue;
 
      try {
        if (vaccine.isOverdue) {
          await _generateOverdueNotification(vaccine, childName);
        } else {
          final daysUntil = vaccine.dueDate.difference(DateTime.now()).inDays;
          if (daysUntil >= 0 && daysUntil <= 14) {
            await _generateUpcomingNotification(vaccine, childName, daysUntil);
          }
        }
      } catch (e) {
        debugPrint('VaccineNotificationGenerator error for ${vaccine.name}: $e');
      }
    }
  }
 
  Future<void> _generateOverdueNotification(
    VaccineEntry vaccine,
    String childName,
  ) async {
    final week = _weekNumber(DateTime.now());
    final id = 'notif_${vaccine.id}_overdue_${DateTime.now().year}_w$week';
 
    final alreadyExists = await _repo.exists(id);
    if (alreadyExists) return; 
 
    final notification = NotificationModel(
      id: id,
      type: NotificationType.vaccination,
      title: '⚠️ OVERDUE: ${vaccine.name} for $childName',
      body: '${vaccine.name} for $childName was due on ${_formatDate(vaccine.dueDate)} '
          'and has not yet been administered.\n\n'
          'Please visit your nearest Regional Health Office, PHM (Public Health '
          'Midwife), or hospital as soon as possible to get this vaccine '
          'administered. Delayed vaccination increases the risk of infection.\n\n'
          'Bring your child\'s Health Development Record (CHDR) book when you go.',
      createdAt: DateTime.now(),
      isRead: false,
    );
 
    await _repo.save(notification);
    debugPrint('VaccineNotificationGenerator: saved overdue notification for ${vaccine.name}');
  }
 
  Future<void> _generateUpcomingNotification(
    VaccineEntry vaccine,
    String childName,
    int daysUntil,
  ) async {
    final week = _weekNumber(DateTime.now());
    final id = 'notif_${vaccine.id}_upcoming_${DateTime.now().year}_w$week';
 
    final alreadyExists = await _repo.exists(id);
    if (alreadyExists) return;
 
    final String daysText = daysUntil == 0
        ? 'today'
        : daysUntil == 1
            ? 'tomorrow'
            : 'in $daysUntil days';
 
    final notification = NotificationModel(
      id: id,
      type: NotificationType.vaccination,
      title: '${vaccine.name} for $childName is due $daysText',
      body: '${vaccine.name} for $childName is scheduled for '
          '${_formatDate(vaccine.dueDate)} ($daysText).\n\n'
          'Plan a visit to your Regional Health Office or hospital to get this '
          'vaccine administered on time. On-time vaccination ensures your child '
          'is fully protected.\n\n'
          'Bring your child\'s Health Development Record (CHDR) book.',
      createdAt: DateTime.now(),
      isRead: false,
    );
 
    await _repo.save(notification);
    debugPrint('VaccineNotificationGenerator: saved upcoming notification for ${vaccine.name}');
  }
 
  int _weekNumber(DateTime date) {
    final dayOfYear = int.parse(
      date.difference(DateTime(date.year, 1, 1)).inDays.toString(),
    );
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
 
  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}