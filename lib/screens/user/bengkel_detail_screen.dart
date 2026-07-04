import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/top_bar.dart';
import 'booking/booking_flow_screen.dart';

class BengkelDetailScreen extends StatelessWidget {
  final String bengkelId;

  const BengkelDetailScreen({super.key, required this.bengkelId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final bengkel = app.bengkelById(bengkelId);
    if (bengkel == null) {
      return const Scaffold(
        body: Center(child: Text('Bengkel tidak ditemukan')),
      );
    }

    final hasParts = bengkel.id == 'b1';
    final spareparts = app.spareparts;

    return Scaffold(
      appBar: TopBar(
        title: bengkel.nama,
        subtitle: bengkel.spesialis,
        showBack: true,
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bengkel.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bengkel.spesialis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.ratingStar,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppFormatters.fmtRating(bengkel.rating),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${bengkel.ulasan} ulasan',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      bengkel.buka ? 'Buka sekarang' : 'Tutup',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: bengkel.buka
                            ? AppColors.amanFg
                            : AppColors.batalFg,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 14),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          '${bengkel.alamat} · ${bengkel.jarak} · Buka ${bengkel.jam}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            openBookingFlow(context, bengkelId: bengkel.id),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text(
                          'Ajukan Service',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () => showDemoSnackbar(
                        context,
                        'Menghubungi bengkel (demo)',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.chipBg,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text(
                        'Hubungi',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (hasParts) ...[
            const SizedBox(height: 16),
            const Text(
              'Katalog Sparepart & Harga',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (spareparts.isEmpty)
              const EmptyState(
                icon: Icons.inventory_2_outlined,
                message: 'Belum ada sparepart di katalog bengkel ini.',
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: spareparts.map((p) {
                    final stokColor = p.stok > 5
                        ? AppColors.amanFg
                        : (p.stok > 0 ? AppColors.segeraFg : AppColors.batalFg);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      p.kategori,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '· ${p.stok > 0 ? '${p.stok} pcs' : 'Habis'}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: stokColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppFormatters.fmtRp(p.harga),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
