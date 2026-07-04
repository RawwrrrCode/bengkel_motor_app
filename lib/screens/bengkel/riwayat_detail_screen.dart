import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_request.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/top_bar.dart';

class RiwayatDetailScreen extends StatefulWidget {
  final String serviceId;

  const RiwayatDetailScreen({super.key, required this.serviceId});

  @override
  State<RiwayatDetailScreen> createState() => _RiwayatDetailScreenState();
}

class _RiwayatDetailScreenState extends State<RiwayatDetailScreen> {
  late final TextEditingController _saranController;
  late final TextEditingController _bulanController;

  @override
  void initState() {
    super.initState();
    final svc = context.read<AppProvider>().serviceById(widget.serviceId);
    _saranController = TextEditingController(text: svc?.saran ?? '');
    _bulanController = TextEditingController(text: (svc?.saranBulan ?? '').replaceAll('—', ''));
  }

  @override
  void dispose() {
    _saranController.dispose();
    _bulanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final svc = app.serviceById(widget.serviceId);
    if (svc == null) {
      return const Scaffold(body: Center(child: Text('Data tidak ditemukan')));
    }
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(svc.jenis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('${svc.customer} · ${svc.vehLabel}',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                StatusBadgeChip(label: badge.label, bg: badge.bg, fg: badge.fg),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.divider))),
                    child: const Text('Rincian Biaya',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                  ),
                  ...svc.items.map((i) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.divider))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${i.qty}× ${i.nama}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF475467))),
                            Text(AppFormatters.fmtRp(i.subtotal),
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ],
                        ),
                      )),
                  Container(
                    width: double.infinity,
                    color: AppColors.surfaceTint,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        Text(AppFormatters.fmtRp(svc.biaya),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: AppColors.saranIconBg, borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.saranIconFg),
                    ),
                    const SizedBox(width: 9),
                    const Text('Saran Perawatan untuk Pelanggan',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 13),
                TextField(
                  controller: _saranController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tulis rekomendasi perawatan untuk bulan-bulan ke depan...',
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: Color(0xFFE1E6EF), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: Color(0xFFE1E6EF), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                const Text('Rekomendasi tindak lanjut (bulan)',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _bulanController,
                  decoration: InputDecoration(
                    hintText: 'mis. Agustus 2026',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE1E6EF), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE1E6EF), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      context.read<AppProvider>().saveSaran(
                            svc.id,
                            saran: _saranController.text.trim(),
                            saranBulan: _bulanController.text.trim(),
                          );
                      showDemoSnackbar(context, 'Saran perawatan tersimpan');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    child: const Text('Simpan Saran',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
