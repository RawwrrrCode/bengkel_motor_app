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

class HistoriDetailScreen extends StatelessWidget {
  final String serviceId;

  const HistoriDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final svc = app.serviceById(serviceId);
    if (svc == null) {
      return const Scaffold(body: Center(child: Text('Data tidak ditemukan')));
    }
    final bengkel = app.bengkelById(svc.bengkelId);
    final badge = svc.status.badge;

    return Scaffold(
      appBar: TopBar(title: svc.id, subtitle: svc.jenis, showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        svc.jenis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        svc.vehLabel,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
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
            padding: const EdgeInsets.all(18),
            child: StatusTimeline(status: svc.status),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: const Text(
                    'Informasi Service',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _infoRow('Bengkel', bengkel?.nama ?? '-'),
                _infoRow(
                  'Jadwal',
                  '${AppFormatters.fmtDate(svc.tanggal)} · ${svc.jam}',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keluhan',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        svc.keluhan,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (svc.items.isNotEmpty) ...[
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    child: const Text(
                      'Rincian Biaya',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...svc.items.map(
                    (i) => _infoRow(
                      '${i.qty}× ${i.nama}',
                      AppFormatters.fmtRp(i.subtotal),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: AppColors.surfaceTint,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          AppFormatters.fmtRp(svc.biaya),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (svc.saran.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.saranBg1, AppColors.saranBg2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.saranBorder),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.saranIconBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          size: 19,
                          color: AppColors.saranIconFg,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'Saran dari Bengkel',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: AppColors.saranTitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Text(
                    svc.saran,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.saranText,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFFADFB2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 15,
                          color: AppColors.saranIconFg,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Rekomendasi tindak lanjut: ${svc.saranBulan}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.saranTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (svc.status == ServiceStatus.selesai && svc.mine) ...[
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
                  Text(
                    svc.rating == 0
                        ? 'Beri Rating untuk Bengkel'
                        : 'Rating Kamu',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (i) {
                      final starValue = i + 1;
                      final filled = svc.rating > 0 && starValue <= svc.rating;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: svc.rating == 0
                            ? InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  context.read<AppProvider>().rateService(
                                    svc.id,
                                    starValue,
                                  );
                                  showDemoSnackbar(
                                    context,
                                    'Terima kasih atas penilaianmu!',
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.star_border,
                                    size: 28,
                                    color: AppColors.ratingStar,
                                  ),
                                ),
                              )
                            : Icon(
                                filled ? Icons.star : Icons.star_border,
                                size: 26,
                                color: AppColors.ratingStar,
                              ),
                      );
                    }),
                  ),
                  if (svc.rating > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Terima kasih telah memberi rating ${svc.rating}/5 untuk servis ini.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
