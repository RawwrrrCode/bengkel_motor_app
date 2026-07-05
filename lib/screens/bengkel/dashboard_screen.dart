import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_request.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/top_bar.dart';
import 'pengajuan_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final all = app.servicesForBengkel(app.myBengkelId!);
    final incoming = all.where((s) => s.status != ServiceStatus.selesai && s.status != ServiceStatus.batal).toList();
    final selesai = all.where((s) => s.status == ServiceStatus.selesai).toList();
    final pending = incoming.where((s) => s.status == ServiceStatus.menunggu).toList();
    final menunggu = pending.length;
    final dikerjakan = incoming.where((s) => s.status == ServiceStatus.dikerjakan).length;
    final revenue = selesai.fold<int>(0, (a, s) => a + s.biaya);

    final stats = [
      ('Menunggu', '$menunggu', AppColors.menungguFg, AppColors.menungguBg),
      ('Dikerjakan', '$dikerjakan', AppColors.dikerjakanFg, AppColors.dikerjakanBg),
      ('Selesai', '${selesai.length}', AppColors.selesaiFg, AppColors.selesaiBg),
      ('Pendapatan', AppFormatters.fmtRp(revenue), AppColors.dikonfirmasiFg, AppColors.dikonfirmasiBg),
    ];

    final topIncoming = incoming.take(3).toList();

    return Scaffold(
      appBar: TopBar(
        title: 'Dashboard',
        subtitle: app.myBengkel?.nama ?? '',
        showLogo: true,
        showBell: true,
        hasNotification: pending.isNotEmpty,
        onBellTap: () => _showNotifications(context, pending),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 11,
            crossAxisSpacing: 11,
            childAspectRatio: 1.7,
            children: stats.map((s) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.$1, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(s.$2,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 21, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const Text('Pengajuan Terbaru',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary)),
          const SizedBox(height: 11),
          if (topIncoming.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Belum ada pengajuan masuk.', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...topIncoming.map((p) {
              final badge = p.status.badge;
              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PengajuanDetailScreen(serviceId: p.id))),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTint(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(p.customer.isNotEmpty ? p.customer[0] : '?',
                                    style: const TextStyle(
                                        color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.customer,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                                    const SizedBox(height: 1),
                                    Text(p.jenis,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              StatusBadgeChip(label: badge.label, bg: badge.bg, fg: badge.fg),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 9),
                            margin: const EdgeInsets.only(top: 9),
                            decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: AppColors.divider))),
                            child: Text('${p.vehLabel} · ${AppFormatters.fmtDate(p.tanggal)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context, List<ServiceRequest> pending) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E6EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pengajuan Menunggu Konfirmasi',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                Expanded(
                  child: pending.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada pengajuan baru yang menunggu.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          children: pending.map((p) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PengajuanDetailScreen(serviceId: p.id),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: AppColors.divider),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryTint(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          p.customer.isNotEmpty ? p.customer[0] : '?',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.customer,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13.5,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              '${p.jenis} · ${p.vehLabel}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${AppFormatters.fmtDate(p.tanggal)} · ${p.jam}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
