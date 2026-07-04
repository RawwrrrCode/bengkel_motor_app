import 'package:flutter/material.dart';

import '../services/reminder_service.dart';

class DueBadge extends StatelessWidget {
  final DueStatus status;

  const DueBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case DueStatus.overdue:
        color = Colors.red;
        label = 'Terlambat';
        break;
      case DueStatus.dueSoon:
        color = Colors.orange;
        label = 'Segera';
        break;
      case DueStatus.ok:
        color = Colors.green;
        label = 'Aman';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
