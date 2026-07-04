import 'package:flutter/material.dart';

class StatusBadgeChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final double fontSize;

  const StatusBadgeChip({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.fontSize = 11.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
