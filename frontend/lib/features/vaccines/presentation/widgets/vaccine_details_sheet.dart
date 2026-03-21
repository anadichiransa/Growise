import 'package:flutter/material.dart';
import '../../../../data/models/vaccination.dart';

class VaccineDetailsSheet extends StatelessWidget {
  final ImmunizationRecord record;
  const VaccineDetailsSheet({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: const Color(0xFF210F37),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              record.vaccineName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            _chip(record.ageLabel),
            const SizedBox(height: 16),
            _section('Diseases Prevented', record.diseasesPrevented.join(', ')),
            _section('Scheduled Date', _formatDate(record.scheduledDate)),
            if (record.administeredDate != null)
              _section(
                'Administered Date',
                _formatDate(record.administeredDate),
              ),
            if (record.administeredBy != null)
              _section('Given At', record.administeredBy!),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),
            const Text(
              'Side Effects Info',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _sideEffectsCard(),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF3B1E54),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    ),
  );

  Widget _section(String title, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    ),
  );

  Widget _sideEffectsCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF2D1B69),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common (Minor)',
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '• Redness, swelling, or pain at injection site\n• Mild fever\n• General body aches or restlessness\nThese usually do not require special treatment.',
          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 12),
        const Text(
          'Rare / Severe',
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '• High fever\n• Fainting or excessive drowsiness\n• Allergic reactions (e.g. skin rashes)\nContact your PHM, PHI, MOH, or clinic doctor immediately.',
          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
        ),
      ],
    ),
  );

  String _formatDate(DateTime? d) {
    if (d == null) return 'N/A';
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}
