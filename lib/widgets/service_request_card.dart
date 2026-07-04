import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Generic bordered white card used for Histori/Pengajuan/Riwayat list rows.
/// Each usage supplies its own header/title/subtitle/footer content since the
/// three screens surface slightly different fields, but share the same shell:
/// header row, bold title, muted subtitle, divider, footer row.
class ServiceRequestCard extends StatelessWidget {
  final Widget header;
  final String title;
  final String? subtitle;
  final Widget footerLeft;
  final Widget footerRight;
  final VoidCallback onTap;

  const ServiceRequestCard({
    super.key,
    required this.header,
    required this.title,
    this.subtitle,
    required this.footerLeft,
    required this.footerRight,
    required this.onTap,
  });

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
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 7),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 11),
              Container(
                padding: const EdgeInsets.only(top: 11),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [footerLeft, footerRight],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
