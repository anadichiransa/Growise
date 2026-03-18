import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  final String? message;
  final String? status;
  final String? summary;
  final bool isOnline;

  const StatusBanner({
    super.key,
    this.message,
    this.status,
    this.summary,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = message ?? status ?? summary ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isOnline ? const Color(0xFF4CAF50) : Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (status != null)
            Text(status!,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          if (summary != null)
            Text(summary!,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          if (message != null)
            Text(message!,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
