import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vaccination.dart';

class VaccineRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<AgeGroup>> getImmunizationSchedule(String childId) async {
    final existing = await _db
        .collection('children')
        .doc(childId)
        .collection('immunization_records')
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _generateScheduleForChild(childId);
    }

    final snapshot = await _db
        .collection('children')
        .doc(childId)
        .collection('immunization_records')
        .orderBy('age_months')
        .get();

    final grouped = <String, Map<String, dynamic>>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final scheduledDate = (data['scheduled_date'] as Timestamp).toDate();
      final daysUntilDue = scheduledDate.difference(DateTime.now()).inDays;

      String status = data['status'] ?? 'pending';
      if (status == 'pending' && daysUntilDue < -7) {
        status = 'overdue';
      }

      final record = ImmunizationRecord(
        vaccineId: data['vaccine_id'],
        vaccineName: data['vaccine_name'],
        ageLabel: data['age_label'],
        ageMonths: data['age_months'],
        diseasesPrevented: List<String>.from(data['diseases_prevented'] ?? []),
        status: status,
        scheduledDate: scheduledDate,
        administeredDate: data['administered_date'] != null
            ? (data['administered_date'] as Timestamp).toDate()
            : null,
        administeredBy: data['administered_by'],
        batchNumber: data['batch_number'],
        daysUntilDue: daysUntilDue,
        isBooster: data['is_booster'] ?? false,
        notes: data['notes'] ?? '',
      );

      final label = data['age_label'] as String;
      if (!grouped.containsKey(label)) {
        grouped[label] = {
          'age_label': label,
          'age_months': data['age_months'],
          'vaccines': <ImmunizationRecord>[],
        };
      }
      (grouped[label]!['vaccines'] as List<ImmunizationRecord>).add(record);
    }

    return grouped.values.map((g) {
      final vaccines = g['vaccines'] as List<ImmunizationRecord>;
      return AgeGroup(
        ageLabel: g['age_label'],
        ageMonths: g['age_months'],
        vaccines: vaccines,
        allDone: vaccines.every((v) => v.status == 'done'),
      );
    }).toList();
  }

  Future<void> _generateScheduleForChild(String childId) async {
    final childDoc = await _db.collection('children').doc(childId).get();
    if (!childDoc.exists) return;

    final child = childDoc.data()!;

    // Handle birthDate field (not dob)
    final dobRaw = child['birthDate'];
    if (dobRaw == null) return;
    final dob = (dobRaw as Timestamp).toDate();

    // Handle "Boy"/"Girl" gender values
    final genderRaw = (child['gender'] ?? 'Boy').toString().toLowerCase();
    final gender = (genderRaw == 'girl' || genderRaw == 'female') ? 'female' : 'male';

    final templates = await _db.collection('vaccination_schedule').get();
    final batch = _db.batch();

    for (final template in templates.docs) {
      final v = template.data();

      if (v['gender_restriction'] != null && v['gender_restriction'] != gender) {
        continue;
      }

      final ageMonths = v['age_months'] as int;
      final scheduledDate = DateTime(
        dob.year,
        dob.month + ageMonths,
        dob.day,
      );

      final daysUntilDue = scheduledDate.difference(DateTime.now()).inDays;
      final status = daysUntilDue < -30 ? 'overdue' : 'pending';

      final ref = _db
          .collection('children')
          .doc(childId)
          .collection('immunization_records')
          .doc(v['vaccine_id']);

      batch.set(ref, {
        'vaccine_id': v['vaccine_id'],
        'vaccine_name': v['vaccine_name'],
        'age_label': v['age_label'],
        'age_months': ageMonths,
        'diseases_prevented': v['diseases_prevented'],
        'status': status,
        'scheduled_date': Timestamp.fromDate(scheduledDate),
        'administered_date': null,
        'administered_by': null,
        'batch_number': null,
        'is_booster': v['is_booster'],
        'notes': v['notes'] ?? '',
        'marked_by_parent': false,
        'created_at': Timestamp.now(),
      });
    }

    await batch.commit();
  }

  Future<void> markVaccineDone(
    String childId,
    String vaccineId,
    Map<String, dynamic> body,
  ) async {
    await _db
        .collection('children')
        .doc(childId)
        .collection('immunization_records')
        .doc(vaccineId)
        .update({
      'status': 'done',
      'administered_date': Timestamp.fromDate(DateTime.parse(body['administered_date'])),
      'administered_by': body['administered_by'],
      'batch_number': body['batch_number'],
      'notes': body['notes'],
      'marked_by_parent': true,
      'updated_at': Timestamp.now(),
    });
  }

  Future<List<Map<String, dynamic>>> getUpcomingNotifications(String parentUid) async {
    final childrenSnapshot = await _db
        .collection('children')
        .where('parentId', isEqualTo: parentUid)
        .get();

    final notifications = <Map<String, dynamic>>[];
    final today = DateTime.now();

    for (final childDoc in childrenSnapshot.docs) {
      final childName = childDoc.data()['name'] ?? 'Your child';
      final records = await _db
          .collection('children')
          .doc(childDoc.id)
          .collection('immunization_records')
          .where('status', whereIn: ['pending', 'overdue'])
          .get();

      for (final rec in records.docs) {
        final data = rec.data();
        final scheduledDate = (data['scheduled_date'] as Timestamp).toDate();
        final daysUntil = scheduledDate.difference(today).inDays;

        if (daysUntil <= 7) {
          String urgency;
          if (daysUntil < 0) urgency = 'overdue';
          else if (daysUntil == 0) urgency = 'today';
          else if (daysUntil == 1) urgency = 'tomorrow';
          else urgency = 'this_week';

          notifications.add({
            'child_id': childDoc.id,
            'child_name': childName,
            'vaccine_id': data['vaccine_id'],
            'vaccine_name': data['vaccine_name'],
            'scheduled_date': scheduledDate.toIso8601String(),
            'urgency': urgency,
            'days_until_due': daysUntil,
            'show_on_home': ['today', 'tomorrow', 'overdue'].contains(urgency),
            'show_on_notifications': true,
          });
        }
      }
    }

    notifications.sort((a, b) => a['days_until_due'].compareTo(b['days_until_due']));
    return notifications;
  }
}
