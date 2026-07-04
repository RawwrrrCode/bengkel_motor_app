import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_provider.dart';
import '../../../providers/booking_flow_controller.dart';
import '../../../theme/app_colors.dart';

class BookingStep4Success extends StatelessWidget {
  final VoidCallback onFinish;

  const BookingStep4Success({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final controller = context.watch<BookingFlowController>();
    final bengkel = app.bengkelById(controller.bengkelId);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: Color(0xFFE6F6EE), shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 44, color: Color(0xFF16A34A)),
            ),
            const SizedBox(height: 20),
            const Text('Pengajuan Terkirim!',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.55),
                children: [
                  const TextSpan(text: 'Pengajuan servismu ke '),
                  TextSpan(
                      text: bengkel?.nama ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF475467))),
                  const TextSpan(text: ' berhasil dibuat. Menunggu konfirmasi bengkel.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: AppColors.chipBg, borderRadius: BorderRadius.circular(11)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text('No. ${controller.newId ?? '-'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: Color(0xFF475467),
                      letterSpacing: 0.4)),
            ),
            const SizedBox(height: 26),
            FilledButton(
              onPressed: () {
                onFinish();
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Lihat Histori Service',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
