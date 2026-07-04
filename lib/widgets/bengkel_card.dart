import 'package:flutter/material.dart';

import '../models/bengkel.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

class BengkelCard extends StatelessWidget {
  final Bengkel bengkel;
  final VoidCallback onTap;

  const BengkelCard({super.key, required this.bengkel, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.store, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(bengkel.nama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.5,
                                  color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 6),
                        StatusBadgeChip(
                          label: bengkel.buka ? 'Buka' : 'Tutup',
                          bg: bengkel.buka ? AppColors.amanBg : AppColors.batalBg,
                          fg: bengkel.buka ? AppColors.amanFg : AppColors.batalFg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(bengkel.spesialis,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 15, color: AppColors.ratingStar),
                        const SizedBox(width: 4),
                        Text(AppFormatters.fmtRating(bengkel.rating),
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(width: 12),
                        Text(bengkel.jarak,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Text(bengkel.jam,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}
