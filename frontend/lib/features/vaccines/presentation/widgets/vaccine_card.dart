import 'package:flutter/material.dart';
import '../../../../data/models/vaccination.dart';

class VaccineCard extends StatelessWidget {
  final ImmunizationRecord record;
  final VoidCallback onMarkDone;
  final VoidCallback onDetails;

  const VaccineCard({
    super.key,
    required this.record,
    required this.onMarkDone,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDue = record.status == 'pending' &&
                  record.daysUntilDue != null &&
                  record.daysUntilDue! <= 0;
    final isDone = record.status == 'done';
    final isOverdue = record.status == 'overdue';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B69),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDue || isOverdue ? const Color(0xFF00E5CC) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(record.vaccineName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      if (isDone) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle,
                            color: Color(0xFF4CAF50), size: 16),
                      ]
                    ],
                  ),
                ),
                if (isDue || isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOverdue ? Colors.red.shade700 : const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOverdue ? 'OVERDUE' : 'TODAY',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isDone
                  ? 'Given: '
                  : 'Rec: ',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if ((isDue || isOverdue) && !isDone) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMarkDone,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5CC),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return ' , ';
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }
}
