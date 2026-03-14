import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/immunization_provider.dart';

class VaccineBanner extends StatelessWidget {
  final String childId;
  const VaccineBanner({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final urgent = context.watch<ImmunizationProvider>().urgentVaccines;
    if (urgent.isEmpty) return const SizedBox.shrink();

    final isToday = urgent.first.daysUntilDue == 0;
    final isTomorrow = urgent.first.daysUntilDue == 1;
    final isOverdue = urgent.first.daysUntilDue != null &&
                      urgent.first.daysUntilDue! < 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverdue
              ? [Colors.red.shade900, Colors.red.shade700]
              : [const Color(0xFF2D1B69), const Color(0xFF5C35CC)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue ? Colors.red : const Color(0xFF00E5CC),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.notifications_active,
            color: isOverdue ? Colors.orange : const Color(0xFF00E5CC),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue
                      ? '⚠️ Missed Vaccine — Action Needed'
                      : isToday
                          ? '🔔 Vaccine Due Today'
                          : '💉 Vaccine Due Tomorrow',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  urgent.first.vaccineName,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to immunization screen
              Navigator.pushNamed(context, '/immunization',
                  arguments: childId);
            },
            child: const Text('View',
                style: TextStyle(color: Color(0xFF00E5CC))),
          )
        ],
      ),
    );
  }
}