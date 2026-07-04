import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_provider.dart';
import '../../../providers/booking_flow_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

class BookingStep1Vehicle extends StatelessWidget {
  const BookingStep1Vehicle({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = context.watch<AppProvider>().vehicles;
    final controller = context.watch<BookingFlowController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        const Text('Pilih Kendaraan',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...vehicles.map((v) {
          final on = v.id == controller.vehId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Material(
              color: on ? AppColors.primaryTint(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => controller.setVehicle(v.id),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: on ? AppColors.primary : const Color(0xFFE7EBF2), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint(0.1),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.two_wheeler, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.nama,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                            const SizedBox(height: 1),
                            Text('${v.plat} · ${AppFormatters.fmtKm(v.km)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on ? AppColors.primary : Colors.white,
                          border: Border.all(color: on ? AppColors.primary : const Color(0xFFD6DBE4), width: 2),
                        ),
                        child: on ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
