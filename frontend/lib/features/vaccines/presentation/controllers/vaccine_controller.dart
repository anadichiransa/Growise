import 'package:flutter/material.dart';
import '../../../../data/models/vaccination.dart';
import '../../../../data/repositories/vaccine_repository.dart';
import '../../../../shared/services/notification_service.dart';

class VaccineController extends ChangeNotifier {
  final VaccineRepository _repo = VaccineRepository();

  List<AgeGroup> _groupedSchedule = [];
  bool _isLoading = false;
  String? _error;

  List<AgeGroup> get groupedSchedule => _groupedSchedule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Vaccines due today, tomorrow, or overdue — shown on Home page banner
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
      _groupedSchedule = await _repo.getImmunizationSchedule(childId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markVaccineDone(
    String childId,
    String vaccineId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _repo.markVaccineDone(childId, vaccineId, data);
      await loadSchedule(childId); // refresh
    } catch (e) {
      _error = 'Failed to update: $e';
      notifyListeners();
    }
  }

  Future<void> scheduleAllNotifications(String childName) async {
    int id = 1;
    for (final group in _groupedSchedule) {
      for (final vaccine in group.vaccines) {
        if (vaccine.status != 'done') {
          await NotificationService.scheduleVaccineReminder(
            id: id++,
            childName: childName,
            vaccineName: vaccine.vaccineName,
            scheduledDate: vaccine.scheduledDate,
          );
        }
      }
    }
  }
}