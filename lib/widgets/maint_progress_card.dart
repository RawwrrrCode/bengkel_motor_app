import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class MaintProgressCard extends StatelessWidget {
  final MaintComputed item;
  final bool showLastLabel;

  const MaintProgressCard({super.key, required this.item, this.showLastLabel = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(item.nama,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: AppColors.textPrimary)),
              ),
              StatusBadgeChip(
                  label: item.badge.label, bg: item.badge.bg, fg: item.badge.fg),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: item.progressPct / 100,
              minHeight: 7,
              backgroundColor: const Color(0xFFEEF1F6),
              valueColor: AlwaysStoppedAnimation(item.barColor),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.intervalLabel,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(item.nextLabel,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475467),
                      fontWeight: FontWeight.w700)),
            ],
          ),
          if (showLastLabel) ...[
            const SizedBox(height: 4),
            Text(item.lastLabel,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}
