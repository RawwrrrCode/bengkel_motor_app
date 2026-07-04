import 'package:flutter/material.dart';

import '../models/service_request.dart';
import '../theme/app_colors.dart';

class StatusTimeline extends StatelessWidget {
  final ServiceStatus status;

  const StatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = buildTimeline(status);
    return Column(
      children: steps.map((step) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: step.done ? AppColors.primary : const Color(0xFFEEF1F6),
                      shape: BoxShape.circle,
                      border: step.done
                          ? null
                          : Border.all(color: const Color(0xFFE1E6EF), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      step.num,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: step.done ? Colors.white : const Color(0xFFB4BCCB),
                      ),
                    ),
                  ),
                  if (!step.isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        color: step.done ? AppColors.primary : const Color(0xFFE7EBF2),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 12),
                child: Text(
                  step.label,
                  style: TextStyle(
                    fontWeight: step.done ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13.5,
                    color: step.done ? AppColors.textPrimary : const Color(0xFFA6AEBD),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
