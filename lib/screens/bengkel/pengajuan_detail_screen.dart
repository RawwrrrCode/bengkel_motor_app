import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_request.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/top_bar.dart';
import 'complete_service_screen.dart';

class PengajuanDetailScreen extends StatelessWidget {
  final String serviceId;

  const PengajuanDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final svc = app.serviceById(serviceId);
    if (svc == null) {
      return const Scaffold(body: Center(child: Text('Data tidak ditemukan')));
    }
    final badge = svc.status.badge;
    final canReject = svc.status == ServiceStatus.menunggu;
    final canAdvance = svc.status != ServiceStatus.selesai && svc.status != ServiceStatus.batal;

    return Scaffold(
      appBar: TopBar(title: svc.id, subtitle: svc.jenis, showBack: true),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint(0.1),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            alignment: Alignment.center,
                            child: Text(svc.customer.isNotEmpty ? svc.customer[0] : '?',
                                style: const TextStyle(
                                    color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 17)),
                          ),
                          const SizedBox(width: 11),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(svc.customer,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary)),
                              Text(svc.vehLabel,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      StatusBadgeChip(label: badge.label, bg: badge.bg, fg: badge.fg),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _row('Layanan', svc.jenis),
                      _row('Jadwal', '${AppFormatters.fmtDate(svc.tanggal)} · ${svc.jam}'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Keluhan',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(svc.keluhan,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status Pengerjaan',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 14),
                      StatusTimeline(status: svc.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (canAdvance)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.cardBorderLight)),
              ),
              child: Row(
                children: [
                  if (canReject)
                    FilledButton(
                      onPressed: () => _confirmReject(context, svc),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.batalBg,
                        foregroundColor: AppColors.batalFg,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      child: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  if (canReject) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (svc.status == ServiceStatus.dikerjakan) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CompleteServiceScreen(serviceId: svc.id)),
                          );
                        } else {
                          context.read<AppProvider>().advanceStatus(svc.id);
                          showDemoSnackbar(context, 'Status pesanan diperbarui');
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      child: Text(svc.status.advanceActionLabel,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmReject(BuildContext context, ServiceRequest svc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pengajuan?'),
        content: Text(
            'Pengajuan ${svc.jenis} dari ${svc.customer} akan ditolak dan tidak bisa diproses lagi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tolak', style: TextStyle(color: AppColors.batalFg)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AppProvider>().rejectRequest(svc.id);
      showDemoSnackbar(context, 'Pengajuan ditolak');
    }
  }

  Widget _row(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
