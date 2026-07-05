import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/maint_progress_card.dart';
import '../../widgets/top_bar.dart';
import 'bengkel_list_screen.dart';
import 'perawatan_rutin_screen.dart';

class VehicleDetailScreen extends StatelessWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<AppProvider>().vehicleById(vehicleId);
    if (vehicle == null) {
      return const Scaffold(body: Center(child: Text('Kendaraan tidak ditemukan')));
    }

    final maintTop = vehicle.computeMaint().take(3).toList();
    final specRows = <MapEntry<String, String>>[
      MapEntry('Merk', vehicle.merk),
      MapEntry('Tahun', '${vehicle.tahun}'),
      MapEntry('Warna', vehicle.warna),
      MapEntry('Tipe', vehicle.tipe),
      MapEntry('Kapasitas', '${vehicle.cc} cc'),
      MapEntry('Odometer', AppFormatters.fmtKm(vehicle.km)),
    ];

    return Scaffold(
      appBar: TopBar(title: vehicle.nama, subtitle: vehicle.plat, showBack: true),
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
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint(0.1),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(Icons.two_wheeler, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vehicle.nama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('${vehicle.plat} · ${vehicle.warna}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTint,
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Odometer saat ini',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(AppFormatters.fmtKm(vehicle.km),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.cardBorderLight),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.speed_outlined, color: AppColors.primary, size: 22),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Spesifikasi',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: specRows.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.divider))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
                      Text(e.value,
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Perawatan Rutin',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PerawatanRutinScreen(vehicleId: vehicle.id))),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text('Lihat semua',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...maintTop.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MaintProgressCard(item: m),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BengkelListScreen(vehId: vehicle.id)),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Ajukan Service Kendaraan Ini',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
