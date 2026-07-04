import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({super.key, required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dueCount = vehicle.dueCount;
    final isDue = dueCount > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.two_wheeler, color: AppColors.primary, size: 27),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vehicle.nama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            '${vehicle.plat} · ${vehicle.tahun} · ${AppFormatters.fmtKm(vehicle.km)}',
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textFaint),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceTint,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDue ? AppColors.segeraBar : AppColors.amanBar,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDue ? '$dueCount perawatan perlu dicek' : 'Semua terawat baik',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDue ? AppColors.segeraFg : AppColors.amanFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
