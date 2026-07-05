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
import 'pengajuan_detail_screen.dart';
import 'riwayat_detail_screen.dart';

/// Combines the incoming-requests queue and the completed-service history
/// into one tab (toggle at the top), since they're both just different
/// status slices of the same `servicesForBengkel` list.
class PengajuanListScreen extends StatefulWidget {
  const PengajuanListScreen({super.key});

  @override
  State<PengajuanListScreen> createState() => _PengajuanListScreenState();
}

class _PengajuanListScreenState extends State<PengajuanListScreen> {
  String _tab = 'aktif';
  String _filter = 'semua';

  static const _chips = [
    ('semua', 'Semua'),
    ('menunggu', 'Menunggu'),
    ('dikonfirmasi', 'Dikonfirmasi'),
    ('dikerjakan', 'Dikerjakan'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final all = app.servicesForBengkel(app.myBengkelId!);
    final isAktif = _tab == 'aktif';

    final allIncoming = all
        .where(
          (s) =>
              s.status != ServiceStatus.selesai &&
              s.status != ServiceStatus.batal,
        )
        .toList();
    final aktif = _filter == 'semua'
        ? allIncoming
        : allIncoming.where((s) => s.status.name == _filter).toList();
    final selesai = all
        .where((s) => s.status == ServiceStatus.selesai)
        .toList();

    return Scaffold(
      appBar: const TopBar(title: 'Pengajuan & Riwayat', showLogo: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _tabButton(
                    'aktif',
                    'Aktif${allIncoming.isEmpty ? '' : ' (${allIncoming.length})'}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _tabButton('selesai', 'Selesai')),
              ],
            ),
          ),
          if (isAktif)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                children: _chips.map((c) {
                  final on = _filter == c.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: on ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setState(() => _filter = c.$1),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: on
                                  ? Colors.transparent
                                  : const Color(0xFFE1E6EF),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Text(
                            c.$2,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: on
                                  ? Colors.white
                                  : const Color(0xFF667085),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            const SizedBox(height: 16),
          Expanded(
            child: isAktif
                ? _aktifList(context, aktif)
                : _selesaiList(context, selesai),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String tab, String label) {
    final on = _tab == tab;
    return Material(
      color: on ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => setState(() => _tab = tab),
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

  Widget _aktifList(BuildContext context, List<ServiceRequest> items) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        message: 'Tidak ada pengajuan di kategori ini.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: items.map((p) {
        final badge = p.status.badge;
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: ServiceRequestCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PengajuanDetailScreen(serviceId: p.id),
              ),
            ),
            header: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint(0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    p.customer.isNotEmpty ? p.customer[0] : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
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
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        p.vehLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadgeChip(label: badge.label, bg: badge.bg, fg: badge.fg),
              ],
            ),
            title: p.jenis,
            footerLeft: Text(
              p.jenis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475467),
              ),
            ),
            footerRight: Text(
              '${AppFormatters.fmtDate(p.tanggal)} · ${p.jam}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _selesaiList(BuildContext context, List<ServiceRequest> items) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.history_outlined,
        message: 'Belum ada servis yang selesai dikerjakan.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: items.map((h) {
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
                StatusBadgeChip(label: badge.label, bg: badge.bg, fg: badge.fg),
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
    );
  }
}
