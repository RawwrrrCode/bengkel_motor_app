import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_request.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/service_request_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/top_bar.dart';
import 'riwayat_detail_screen.dart';

class RiwayatListScreen extends StatelessWidget {
  const RiwayatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final riwayat = app
        .servicesForBengkel(currentBengkelId)
        .where((s) => s.status == ServiceStatus.selesai)
        .toList();

    return Scaffold(
      appBar: const TopBar(title: 'Riwayat Service', showLogo: true),
      body: riwayat.isEmpty
          ? const EmptyState(
              icon: Icons.history_outlined,
              message: 'Belum ada servis yang selesai dikerjakan.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: riwayat.map((h) {
                final badge = h.status.badge;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: ServiceRequestCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RiwayatDetailScreen(serviceId: h.id),
                      ),
                    ),
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${h.id} · ${h.customer}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        StatusBadgeChip(
                          label: badge.label,
                          bg: badge.bg,
                          fg: badge.fg,
                        ),
                      ],
                    ),
                    title: h.jenis,
                    subtitle: h.vehLabel,
                    footerLeft: Text(
                      AppFormatters.fmtDate(h.tanggal),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    footerRight: Text(
                      AppFormatters.fmtRp(h.biaya),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
