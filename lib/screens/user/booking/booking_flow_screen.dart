import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_provider.dart';
import '../../../providers/booking_flow_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/snackbar.dart';
import '../../../widgets/tab_shell.dart';
import 'booking_step1_vehicle.dart';
import 'booking_step2_details.dart';
import 'booking_step3_summary.dart';
import 'booking_step4_success.dart';

/// Opens the "Ajukan Service" wizard as a full-screen route covering the
/// bottom nav (pushed on the root Navigator, not the current tab's nested
/// one). [context] must be a descendant of the User tab shell so we can
/// capture its [TabIndexController] and jump to the Histori tab once the
/// flow finishes.
Future<void> openBookingFlow(
  BuildContext context, {
  String? vehId,
  required String bengkelId,
}) {
  final app = context.read<AppProvider>();
  final tabController = TabIndexScope.of(context);
  final resolvedVehId =
      vehId ?? (app.vehicles.isNotEmpty ? app.vehicles.first.id : null);

  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => BookingFlowController(
          initialVehId: resolvedVehId,
          initialBengkelId: bengkelId,
        ),
        child: BookingFlowScreen(onFinish: () => tabController.value = 3),
      ),
    ),
  );
}

class BookingFlowScreen extends StatelessWidget {
  final VoidCallback onFinish;

  const BookingFlowScreen({super.key, required this.onFinish});

  void _handleBack(BuildContext context, BookingFlowController controller) {
    if (!controller.prev()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BookingFlowController>();

    return PopScope(
      canPop: controller.step >= 4,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context, controller);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: controller.step < 4
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => _handleBack(context, controller),
                        ),
                        const Text(
                          'Ajukan Service',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (controller.step < 4) _WizardStepper(step: controller.step),
              Expanded(
                child: switch (controller.step) {
                  1 => const BookingStep1Vehicle(),
                  2 => const BookingStep2Details(),
                  3 => const BookingStep3Summary(),
                  _ => BookingStep4Success(onFinish: onFinish),
                },
              ),
              if (controller.step < 4)
                _FooterButtons(controller: controller, onBack: _handleBack),
            ],
          ),
        ),
      ),
    );
  }
}

class _WizardStepper extends StatelessWidget {
  final int step;

  const _WizardStepper({required this.step});

  @override
  Widget build(BuildContext context) {
    const labels = ['Kendaraan', 'Detail', 'Ringkas'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 6),
      child: Row(
        children: List.generate(labels.length, (i) {
          final n = i + 1;
          final done = step > n;
          final current = step == n;
          final on = done || current;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: on ? AppColors.primary : Colors.white,
                        shape: BoxShape.circle,
                        border: on
                            ? null
                            : Border.all(
                                color: const Color(0xFFE1E6EF),
                                width: 1.5,
                              ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: on ? Colors.white : const Color(0xFF98A2B3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: current
                            ? AppColors.textPrimary
                            : const Color(0xFFA6AEBD),
                      ),
                    ),
                  ],
                ),
                if (i < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(
                        bottom: 18,
                        left: 4,
                        right: 4,
                      ),
                      color: done ? AppColors.primary : const Color(0xFFE1E6EF),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _FooterButtons extends StatelessWidget {
  final BookingFlowController controller;
  final void Function(BuildContext, BookingFlowController) onBack;

  const _FooterButtons({required this.controller, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isLastStep = controller.step == 3;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorderLight)),
      ),
      child: Row(
        children: [
          FilledButton(
            onPressed: () => onBack(context, controller),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.chipBg,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text(
              'Kembali',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () async {
                if (isLastStep) {
                  final app = context.read<AppProvider>();
                  if (app.isSlotTaken(
                    controller.bengkelId,
                    controller.tanggal,
                    controller.jam,
                  )) {
                    showDemoSnackbar(
                      context,
                      'Jam ${controller.jam} di bengkel ini sudah dipesan. Kembali dan pilih jam lain.',
                    );
                    return;
                  }
                  await controller.submit(app);
                } else {
                  controller.next();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                isLastStep ? 'Kirim Pengajuan' : 'Lanjut',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
