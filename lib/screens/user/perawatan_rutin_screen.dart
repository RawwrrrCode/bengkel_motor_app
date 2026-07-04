import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/maint_progress_card.dart';
import '../../widgets/top_bar.dart';

class PerawatanRutinScreen extends StatelessWidget {
  final String vehicleId;

  const PerawatanRutinScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<AppProvider>().vehicleById(vehicleId);
    if (vehicle == null) {
      return const Scaffold(body: Center(child: Text('Kendaraan tidak ditemukan')));
    }

    final maint = vehicle.computeMaint();

    return Scaffold(
      appBar: TopBar(title: 'Perawatan Rutin', subtitle: vehicle.nama, showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryTint(0.08),
              border: Border.all(color: AppColors.primaryTint(0.18)),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                const SizedBox(width: 11),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF3A4A63), height: 1.4),
                      children: [
                        const TextSpan(text: 'Jadwal berbasis '),
                        const TextSpan(
                            text: 'jarak tempuh (km) & waktu',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const TextSpan(text: '. Odometer saat ini '),
                        TextSpan(
                            text: AppFormatters.fmtKm(vehicle.km),
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          ...maint.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: MaintProgressCard(item: m, showLastLabel: true),
              )),
        ],
      ),
    );
  }
}
