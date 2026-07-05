import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/jasa.dart';
import '../../models/service_request.dart';
import '../../models/sparepart.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/top_bar.dart';
import 'booking/booking_flow_screen.dart';

class BengkelDetailScreen extends StatefulWidget {
  final String bengkelId;
  final String? vehId;

  const BengkelDetailScreen({super.key, required this.bengkelId, this.vehId});

  @override
  State<BengkelDetailScreen> createState() => _BengkelDetailScreenState();
}

class _BengkelDetailScreenState extends State<BengkelDetailScreen> {
  late Future<List<Sparepart>> _sparepartsFuture;
  late Future<List<Jasa>> _jasaFuture;
  late Future<List<ServiceRequest>> _reviewsFuture;
  String _catalogTab = 'sparepart';

  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    _sparepartsFuture = app.fetchSparepartsFor(widget.bengkelId);
    _jasaFuture = app.fetchJasaFor(widget.bengkelId);
    _reviewsFuture = app.fetchReviewsFor(widget.bengkelId);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final bengkel = app.bengkelById(widget.bengkelId);
    final vehId = widget.vehId;
    if (bengkel == null) {
      return const Scaffold(
        body: Center(child: Text('Bengkel tidak ditemukan')),
      );
    }

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
                        onPressed: () => openBookingFlow(context,
                            bengkelId: bengkel.id, vehId: vehId),
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
                      onPressed: () => _hubungiBengkel(context, bengkel.telepon),
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
          const SizedBox(height: 16),
          const Text(
            'Katalog & Harga',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _catalogTabButton('sparepart', 'Sparepart')),
              const SizedBox(width: 10),
              Expanded(child: _catalogTabButton('jasa', 'Jasa')),
            ],
          ),
          const SizedBox(height: 10),
          if (_catalogTab == 'sparepart')
            FutureBuilder<List<Sparepart>>(
              future: _sparepartsFuture,
              builder: (context, snapshot) {
                final spareparts = snapshot.data ?? const <Sparepart>[];
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (spareparts.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    message: 'Belum ada sparepart di katalog bengkel ini.',
                  );
                }
                return _catalogCard(
                  spareparts.map((p) {
                    final stokColor = p.stok > 5
                        ? AppColors.amanFg
                        : (p.stok > 0 ? AppColors.segeraFg : AppColors.batalFg);
                    return _catalogRow(
                      nama: p.nama,
                      harga: p.harga,
                      meta: Row(
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
                    );
                  }).toList(),
                );
              },
            )
          else
            FutureBuilder<List<Jasa>>(
              future: _jasaFuture,
              builder: (context, snapshot) {
                final jasaList = snapshot.data ?? const <Jasa>[];
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (jasaList.isEmpty) {
                  return const EmptyState(
                    icon: Icons.build_outlined,
                    message: 'Belum ada jasa di katalog bengkel ini.',
                  );
                }
                return _catalogCard(
                  jasaList
                      .map((j) => _catalogRow(nama: j.nama, harga: j.harga))
                      .toList(),
                );
              },
            ),
          const SizedBox(height: 20),
          const Text(
            'Ulasan Pelanggan',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<ServiceRequest>>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              final reviews = snapshot.data ?? const <ServiceRequest>[];
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (reviews.isEmpty) {
                return const EmptyState(
                  icon: Icons.reviews_outlined,
                  message: 'Belum ada ulasan dari pelanggan lain.',
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: reviews.map((r) {
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint(0.1),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              r.customer.isNotEmpty ? r.customer[0] : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        r.customer,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < r.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 14,
                                          color: AppColors.ratingStar,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${r.jenis} · ${AppFormatters.fmtDate(r.tanggal)}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _hubungiBengkel(BuildContext context, String telepon) async {
    if (telepon.trim().isEmpty) {
      showDemoSnackbar(context, 'Bengkel belum mengisi nomor telepon.');
      return;
    }
    var digits = telepon.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) digits = '62${digits.substring(1)}';
    final uri = Uri.parse('https://wa.me/$digits');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      showDemoSnackbar(context, 'Tidak bisa membuka WhatsApp.');
    }
  }

  Widget _catalogTabButton(String tab, String label) {
    final on = _catalogTab == tab;
    return Material(
      color: on ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => setState(() => _catalogTab = tab),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: on ? Colors.transparent : const Color(0xFFE1E6EF),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: on ? Colors.white : const Color(0xFF667085),
            ),
          ),
        ),
      ),
    );
  }

  Widget _catalogCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }

  Widget _catalogRow({required String nama, required int harga, Widget? meta}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (meta != null) ...[const SizedBox(height: 3), meta],
              ],
            ),
          ),
          Text(
            AppFormatters.fmtRp(harga),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
