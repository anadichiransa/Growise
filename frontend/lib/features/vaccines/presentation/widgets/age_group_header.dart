import 'package:flutter/material.dart';

class AgeGroupHeader extends StatelessWidget {
  final String ageLabel;
  final bool allDone;
  final bool isDueNow;
  final bool isLocked;

  const AgeGroupHeader({
    super.key,
    required this.ageLabel,
    this.allDone = false,
    this.isDueNow = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _iconBgColor()),
            child: Icon(_iconData(), color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(ageLabel,
              style: TextStyle(
                color: isDueNow ? const Color(0xFF00E5CC) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )),
          if (isDueNow) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5CC).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Due Now',
                  style: TextStyle(
                      color: Color(0xFF00E5CC),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            )
          ]
        ],
      ),
    );
  }

  Color _iconBgColor() {
    if (allDone) return const Color(0xFF4CAF50);
    if (isDueNow) return const Color(0xFFFF9800);
    if (isLocked) return Colors.grey.shade700;
    return const Color(0xFF5C35CC);
  }

  IconData _iconData() {
    if (allDone) return Icons.check_circle_outline;
    if (isLocked) return Icons.lock_outline;
    return Icons.circle_outlined;
  }
}
