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
import 'histori_detail_screen.dart';

class HistoriListScreen extends StatelessWidget {
  const HistoriListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final services = app.myServices;

    return Scaffold(
      appBar: const TopBar(title: 'Histori Service', showLogo: true),
      body: services.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              message:
                  'Belum ada riwayat service.\nAjukan service pertamamu dari menu Beranda.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: services.map((s) {
                final bengkel = app.bengkelById(s.bengkelId);
                final badge = s.status.badge;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ServiceRequestCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoriDetailScreen(serviceId: s.id),
                      ),
                    ),
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.id,
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
                    title: s.jenis,
                    subtitle: s.vehLabel,
                    footerLeft: Text(
                      '${AppFormatters.fmtDate(s.tanggal)} · ${bengkel?.nama ?? '-'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    footerRight: Text(
                      s.status == ServiceStatus.selesai
                          ? AppFormatters.fmtRp(s.biaya)
                          : '—',
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
