import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_provider.dart';
import '../../../providers/booking_flow_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../utils/snackbar.dart';

class BookingStep2Details extends StatefulWidget {
  const BookingStep2Details({super.key});

  @override
  State<BookingStep2Details> createState() => _BookingStep2DetailsState();
}

class _BookingStep2DetailsState extends State<BookingStep2Details> {
  late final TextEditingController _keluhanController;

  @override
  void initState() {
    super.initState();
    final controller = context.read<BookingFlowController>();
    _keluhanController = TextEditingController(text: controller.keluhan);
  }

  @override
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final bengkels = app.bengkels;
    final controller = context.watch<BookingFlowController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        const Text(
          'Pilih Bengkel',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 11),
        ...bengkels.map((b) {
          final on = b.id == controller.bengkelId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: on ? AppColors.primaryTint(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => controller.setBengkel(b.id),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: on ? AppColors.primary : const Color(0xFFE7EBF2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${b.spesialis} · ${b.jarak}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 5),
        const Text(
          'Jenis Layanan',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 9),
        _dropdownShell(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: controller.jenis,
              items: jenisLayananList
                  .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.setJenis(v);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tanggal',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 9),
                  _dropdownShell(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.tanggal,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                        );
                        if (picked != null) controller.setTanggal(picked);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppFormatters.fmtDate(controller.tanggal),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jam',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 9),
                  _dropdownShell(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.jam,
                        items: jamSlotList.map((j) {
                          final taken = app.isSlotTaken(
                            controller.bengkelId,
                            controller.tanggal,
                            j,
                          );
                          return DropdownMenuItem(
                            value: j,
                            child: Text(
                              taken ? '$j · Penuh' : j,
                              style: TextStyle(
                                color: taken
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          if (app.isSlotTaken(
                            controller.bengkelId,
                            controller.tanggal,
                            v,
                          )) {
                            showDemoSnackbar(
                              context,
                              'Jam $v di bengkel ini sudah dipesan, pilih jam lain.',
                            );
                            return;
                          }
                          controller.setJam(v);
                        },
                      ),
                    ),
                  ),
                  if (app.isSlotTaken(
                    controller.bengkelId,
                    controller.tanggal,
                    controller.jam,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Jam ini sudah terisi untuk tanggal & bengkel yang dipilih. Pilih jam lain.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.batalFg,
                          height: 1.3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Keluhan / Catatan',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          maxLines: 4,
          onChanged: controller.setKeluhan,
          controller: _keluhanController,
          decoration: InputDecoration(
            hintText: 'Ceritakan keluhan motormu...',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFFE1E6EF),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFFE1E6EF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E6EF), width: 1.5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: child,
    );
  }
}
