import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

enum MaintStatus { lewat, segera, aman }

class MaintBadge {
  final String label;
  final Color bg;
  final Color fg;

  const MaintBadge({required this.label, required this.bg, required this.fg});
}

class MaintComputed {
  final String nama;
  final String intervalLabel;
  final String nextLabel;
  final String lastLabel;
  final MaintStatus status;
  final double progressPct;
  final Color barColor;
  final MaintBadge badge;

  const MaintComputed({
    required this.nama,
    required this.intervalLabel,
    required this.nextLabel,
    required this.lastLabel,
    required this.status,
    required this.progressPct,
    required this.barColor,
    required this.badge,
  });
}

class MaintItem {
  final String nama;
  final int intervalKm;
  final int intervalBulan;
  final int lastKm;
  final String lastLabel;

  const MaintItem({
    required this.nama,
    required this.intervalKm,
    required this.intervalBulan,
    required this.lastKm,
    required this.lastLabel,
  });

  MaintComputed compute(int currentKm) {
    final nextKm = lastKm + intervalKm;
    final remainingKm = nextKm - currentKm;
    final MaintStatus status;
    if (remainingKm < 0) {
      status = MaintStatus.lewat;
    } else if (remainingKm <= 1000) {
      status = MaintStatus.segera;
    } else {
      status = MaintStatus.aman;
    }

    final progressPct = (((currentKm - lastKm) / intervalKm) * 100)
        .clamp(6, 100)
        .toDouble();

    final Color barColor;
    final MaintBadge badge;
    switch (status) {
      case MaintStatus.lewat:
        barColor = AppColors.lewatBar;
        badge = const MaintBadge(
            label: 'Terlewat', bg: AppColors.lewatBg, fg: AppColors.lewatFg);
        break;
      case MaintStatus.segera:
        barColor = AppColors.segeraBar;
        badge = const MaintBadge(
            label: 'Segera', bg: AppColors.segeraBg, fg: AppColors.segeraFg);
        break;
      case MaintStatus.aman:
        barColor = AppColors.amanBar;
        badge = const MaintBadge(
            label: 'Aman', bg: AppColors.amanBg, fg: AppColors.amanFg);
        break;
    }

    final nextLabel = remainingKm < 0
        ? 'Terlewat ${AppFormatters.fmtNumber(remainingKm.abs())} km'
        : '± ${AppFormatters.fmtNumber(remainingKm)} km lagi';

    return MaintComputed(
      nama: nama,
      intervalLabel:
          'Tiap ${AppFormatters.fmtNumber(intervalKm)} km / $intervalBulan bln',
      nextLabel: nextLabel,
      lastLabel:
          'Terakhir ${lastKm > 0 ? '${AppFormatters.fmtNumber(lastKm)} km' : 'baru'} · $lastLabel',
      status: status,
      progressPct: progressPct,
      barColor: barColor,
      badge: badge,
    );
  }
}

class Vehicle {
  final String id;
  final String nama;
  final String merk;
  final String plat;
  final int tahun;
  final String warna;
  final String tipe;
  final int cc;
  final int km;
  final List<MaintItem> maint;

  const Vehicle({
    required this.id,
    required this.nama,
    required this.merk,
    required this.plat,
    required this.tahun,
    required this.warna,
    required this.tipe,
    required this.cc,
    required this.km,
    required this.maint,
  });

  List<MaintComputed> computeMaint() =>
      maint.map((m) => m.compute(km)).toList();

  int get dueCount =>
      computeMaint().where((m) => m.status != MaintStatus.aman).length;
}
