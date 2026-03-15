class ImmunizationRecord {
  final String vaccineId;
  final String vaccineName;
  final String ageLabel;
  final int ageMonths;
  final List<String> diseasesPrevented;
  final String status;
  final DateTime scheduledDate;
  final DateTime? administeredDate;
  final String? administeredBy;
  final String? batchNumber;
  final int? daysUntilDue;
  final bool isBooster;
  final String notes;

  ImmunizationRecord({
    required this.vaccineId,
    required this.vaccineName,
    required this.ageLabel,
    required this.ageMonths,
    required this.diseasesPrevented,
    required this.status,
    required this.scheduledDate,
    this.administeredDate,
    this.administeredBy,
    this.batchNumber,
    this.daysUntilDue,
    this.isBooster = false,
    this.notes = '',
  });

  factory ImmunizationRecord.fromJson(Map<String, dynamic> json) {
    return ImmunizationRecord(
      vaccineId: json['vaccine_id'],
      vaccineName: json['vaccine_name'],
      ageLabel: json['age_label'],
      ageMonths: json['age_months'],
      diseasesPrevented: List<String>.from(json['diseases_prevented'] ?? []),
      status: json['status'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      administeredDate: json['administered_date'] != null
          ? DateTime.parse(json['administered_date'])
          : null,
      administeredBy: json['administered_by'],
      batchNumber: json['batch_number'],
      daysUntilDue: json['days_until_due'],
      isBooster: json['is_booster'] ?? false,
      notes: json['notes'] ?? '',
    );
  }
}

class AgeGroup {
  final String ageLabel;
  final int ageMonths;
  final List<ImmunizationRecord> vaccines;
  final bool allDone;

  AgeGroup({
    required this.ageLabel,
    required this.ageMonths,
    required this.vaccines,
    required this.allDone,
  });

  factory AgeGroup.fromJson(Map<String, dynamic> json) {
    return AgeGroup(
      ageLabel: json['age_label'],
      ageMonths: json['age_months'],
      vaccines: (json['vaccines'] as List)
          .map((v) => ImmunizationRecord.fromJson(v))
          .toList(),
      allDone: json['all_done'] ?? false,
    );
  }
}