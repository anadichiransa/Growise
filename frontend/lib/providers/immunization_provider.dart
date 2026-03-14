import 'package:flutter/material.dart';
import '../models/immunization_record.dart';
import '../services/immunization_service.dart';

class ImmunizationProvider extends ChangeNotifier {
  final ImmunizationService _service = ImmunizationService();

  List<AgeGroup> _groupedSchedule = [];
  bool _isLoading = false;
  String? _error;

  List<AgeGroup> get groupedSchedule => _groupedSchedule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get vaccines due today or tomorrow for Home page banner
  List<ImmunizationRecord> get urgentVaccines {
    return _groupedSchedule
        .expand((g) => g.vaccines)
        .where((v) =>
            v.status != 'done' &&
            v.daysUntilDue != null &&
            v.daysUntilDue! <= 1)
        .toList();
  }

  Future<void> loadSchedule(String childId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groupedSchedule = await _service.getSchedule(childId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _scheduleAllNotifications(String childName) async {
  int idCounter = 1;
  for (final group in _groupedSchedule) {
    for (final vaccine in group.vaccines) {
      if (vaccine.status != 'done') {
        await NotificationService.scheduleVaccineReminder(
          id: idCounter++,
          childName: childName,
          vaccineName: vaccine.vaccineName,
          scheduledDate: vaccine.scheduledDate,
        );
      }
    }
  }
}

  Future<void> markVaccineDone(
    String childId,
    String vaccineId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _service.markDone(childId, vaccineId, data);
      // Update local state optimistically
      for (final group in _groupedSchedule) {
        for (int i = 0; i < group.vaccines.length; i++) {
          if (group.vaccines[i].vaccineId == vaccineId) {
            // Reload to get fresh data
            await loadSchedule(childId);
            return;
          }
        }
      }
    } catch (e) {
      _error = 'Failed to mark vaccine: $e';
      notifyListeners();
    }
  }
}