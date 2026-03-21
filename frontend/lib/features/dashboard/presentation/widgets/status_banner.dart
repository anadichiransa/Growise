import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../vaccines/presentation/controllers/vaccine_controller.dart';

class VaccineBanner extends StatelessWidget {
  final String childId;
  const VaccineBanner({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final urgent = context.watch<VaccineController>().urgentVaccines;
    if (urgent.isEmpty) return const SizedBox.shrink();

    final first = urgent.first;
    final isOverdue = first.daysUntilDue != null && first.daysUntilDue! < 0;
    final isToday = first.daysUntilDue == 0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context, '/vaccines', arguments: childId),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isOverdue
                ? [Colors.red.shade900, Colors.red.shade700]
                : [const Color(0xFF2D1B69), const Color(0xFF5C35CC)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOverdue ? Colors.redAccent : const Color(0xFF00E5CC),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isOverdue
                  ? Icons.warning_amber_rounded
                  : Icons.notifications_active,
              color: isOverdue ? Colors.orange : const Color(0xFF00E5CC),
              size: 26,
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
                  Text(
                    first.vaccineName,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}