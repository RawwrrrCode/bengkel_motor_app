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

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'intervalKm': intervalKm,
    'intervalBulan': intervalBulan,
    'lastKm': lastKm,
    'lastLabel': lastLabel,
  };

  factory MaintItem.fromJson(Map<String, dynamic> json) => MaintItem(
    nama: json['nama'] as String,
    intervalKm: json['intervalKm'] as int,
    intervalBulan: json['intervalBulan'] as int,
    lastKm: json['lastKm'] as int,
    lastLabel: json['lastLabel'] as String,
  );

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
          label: 'Terlewat',
          bg: AppColors.lewatBg,
          fg: AppColors.lewatFg,
        );
        break;
      case MaintStatus.segera:
        barColor = AppColors.segeraBar;
        badge = const MaintBadge(
          label: 'Segera',
          bg: AppColors.segeraBg,
          fg: AppColors.segeraFg,
        );
        break;
      case MaintStatus.aman:
        barColor = AppColors.amanBar;
        badge = const MaintBadge(
          label: 'Aman',
          bg: AppColors.amanBg,
          fg: AppColors.amanFg,
        );
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
  final String ownerUid;
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
    required this.ownerUid,
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

  Map<String, dynamic> toJson() => {
    'ownerUid': ownerUid,
    'nama': nama,
    'merk': merk,
    'plat': plat,
    'tahun': tahun,
    'warna': warna,
    'tipe': tipe,
    'cc': cc,
    'km': km,
    'maint': maint.map((m) => m.toJson()).toList(),
  };

  factory Vehicle.fromJson(String id, Map<String, dynamic> json) => Vehicle(
    id: id,
    ownerUid: json['ownerUid'] as String,
    nama: json['nama'] as String,
    merk: json['merk'] as String,
    plat: json['plat'] as String,
    tahun: json['tahun'] as int,
    warna: json['warna'] as String,
    tipe: json['tipe'] as String,
    cc: json['cc'] as int,
    km: json['km'] as int,
    maint: (json['maint'] as List)
        .map((m) => MaintItem.fromJson(m as Map<String, dynamic>))
        .toList(),
  );
}
