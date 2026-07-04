import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_provider.dart';
import '../../../providers/booking_flow_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class BookingStep3Summary extends StatelessWidget {
  const BookingStep3Summary({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final controller = context.watch<BookingFlowController>();
    final vehicle = app.vehicleById(controller.vehId);
    final bengkel = app.bengkelById(controller.bengkelId);

    final rows = <MapEntry<String, String>>[
      MapEntry('Kendaraan', vehicle != null ? '${vehicle.nama} · ${vehicle.plat}' : '-'),
      MapEntry('Bengkel', bengkel?.nama ?? '-'),
      MapEntry('Jenis Layanan', controller.jenis),
      MapEntry('Tanggal', AppFormatters.fmtDate(controller.tanggal)),
      MapEntry('Jam', controller.jam),
      MapEntry('Keluhan', controller.keluhan.isEmpty ? '-' : controller.keluhan),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        const Text('Ringkasan Pengajuan',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: rows.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.divider))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(e.value,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryTint(0.07),
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: const Text(
            'Bengkel akan meninjau pengajuanmu dan mengirim konfirmasi. Kamu bisa memantau status di menu Histori.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF3A4A63), height: 1.5),
          ),
        ),
      ],
    );
  }
}
