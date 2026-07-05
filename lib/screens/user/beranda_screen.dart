import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_request.dart';
import '../../models/vehicle.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/tab_shell.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/vehicle_card.dart';
import 'bengkel_list_screen.dart';
import 'histori_detail_screen.dart';
import 'perawatan_rutin_screen.dart';
import 'vehicle_detail_screen.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final active = app.activeMyService;

    final alerts = <MapEntry<Vehicle, MaintComputed>>[];
    for (final v in app.vehicles) {
      for (final m in v.computeMaint()) {
        if (m.status != MaintStatus.aman) alerts.add(MapEntry(v, m));
      }
    }
    final topAlerts = alerts.take(3).toList();

    // Status changes the bengkel made that the customer hasn't necessarily
    // seen yet: confirmed/started/rejected, or completed-but-not-rated.
    final serviceAlerts = app.myServices
        .where(
          (s) =>
              s.status == ServiceStatus.dikonfirmasi ||
              s.status == ServiceStatus.dikerjakan ||
              s.status == ServiceStatus.batal ||
              (s.status == ServiceStatus.selesai && s.rating == 0),
        )
        .toList();

    return Scaffold(
      appBar: TopBar(
        title: 'Halo, ${app.displayName}',
        subtitle: 'Ayo rawat motormu hari ini',
        showLogo: true,
        showBell: true,
        hasNotification: alerts.isNotEmpty || serviceAlerts.isNotEmpty,
        onBellTap: () => _showNotifications(context, alerts, serviceAlerts),
        onLogout: () => context.read<AppProvider>().signOut(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (active != null) _ActiveServiceCard(service: active),
          if (active != null) const SizedBox(height: 18),
          const _AjukanServiceButton(),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Perawatan Perlu Dicek',
            onLihatSemua: () {
              if (app.vehicles.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PerawatanRutinScreen(vehicleId: app.vehicles.first.id),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 11),
          if (topAlerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Semua kendaraan dalam kondisi aman.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          else
            Column(
              children: topAlerts.map((entry) {
                final vehicle = entry.key;
                final m = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VehicleDetailScreen(vehicleId: vehicle.id),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.cardBorder),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.build_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${vehicle.nama} · ${m.nextLabel}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: m.badge.bg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                m.badge.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: m.badge.fg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 6),
          _SectionHeader(
            title: 'Kendaraan Saya',
            onLihatSemua: () => TabIndexScope.of(context).value = 1,
          ),
          const SizedBox(height: 11),
          Column(
            children: app.vehicles
                .map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: VehicleCard(
                      vehicle: v,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleDetailScreen(vehicleId: v.id),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showNotifications(
    BuildContext context,
    List<MapEntry<Vehicle, MaintComputed>> alerts,
    List<ServiceRequest> serviceAlerts,
  ) {
    final app = context.read<AppProvider>();
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
                      'Notifikasi',
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
                  child: (alerts.isEmpty && serviceAlerts.isEmpty)
                      ? const Center(
                          child: Text(
                            'Tidak ada notifikasi baru.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          children: [
                            if (serviceAlerts.isNotEmpty) ...[
                              _sectionLabel('Update Pengajuan'),
                              ...serviceAlerts.map(
                                (s) => _serviceAlertTile(
                                  context,
                                  sheetContext,
                                  app,
                                  s,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            if (alerts.isNotEmpty) ...[
                              _sectionLabel('Perawatan Perlu Dicek'),
                              ...alerts.map(
                                (entry) => _maintAlertTile(
                                  context,
                                  sheetContext,
                                  entry,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _serviceAlertTile(
    BuildContext context,
    BuildContext sheetContext,
    AppProvider app,
    ServiceRequest s,
  ) {
    final badge = s.status.badge;
    final needsRating = s.status == ServiceStatus.selesai && s.rating == 0;
    final bengkelNama = app.bengkelById(s.bengkelId)?.nama ?? 'Bengkel';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(sheetContext);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HistoriDetailScreen(serviceId: s.id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
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
                child: Icon(
                  needsRating ? Icons.star_border : Icons.build_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      needsRating ? 'Beri rating untuk servis' : s.jenis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$bengkelNama · ${s.vehLabel}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badge.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badge.fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _maintAlertTile(
    BuildContext context,
    BuildContext sheetContext,
    MapEntry<Vehicle, MaintComputed> entry,
  ) {
    final vehicle = entry.key;
    final m = entry.value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(sheetContext);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VehicleDetailScreen(vehicleId: vehicle.id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.build_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${vehicle.nama} · ${m.nextLabel}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: m.badge.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  m.badge.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: m.badge.fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onLihatSemua;

  const _SectionHeader({required this.title, required this.onLihatSemua});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15.5,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onLihatSemua,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
          ),
          child: const Text(
            'Lihat semua',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _AjukanServiceButton extends StatelessWidget {
  const _AjukanServiceButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BengkelListScreen()),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajukan Service',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Booking servis ke bengkel pilihanmu',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveServiceCard extends StatelessWidget {
  final ServiceRequest service;

  const _ActiveServiceCard({required this.service});

  static const _pctMap = {
    ServiceStatus.menunggu: 22,
    ServiceStatus.dikonfirmasi: 50,
    ServiceStatus.dikerjakan: 78,
    ServiceStatus.selesai: 100,
  };

  static const _stepTextMap = {
    ServiceStatus.menunggu: 'Menunggu konfirmasi bengkel',
    ServiceStatus.dikonfirmasi: 'Dikonfirmasi — menunggu dikerjakan',
    ServiceStatus.dikerjakan: 'Motor sedang dikerjakan',
    ServiceStatus.selesai: 'Selesai',
  };

  @override
  Widget build(BuildContext context) {
    final pct = _pctMap[service.status] ?? 0;
    final badge = service.status.badge;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoriDetailScreen(serviceId: service.id),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SERVICE BERJALAN',
                    style: TextStyle(
                      fontSize: 11.5,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                service.jenis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                service.vehLabel,
                style: const TextStyle(fontSize: 12.5, color: Colors.white70),
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.24),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _stepTextMap[service.status] ?? '',
                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
