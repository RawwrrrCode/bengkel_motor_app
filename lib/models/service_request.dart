import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum ServiceStatus { menunggu, dikonfirmasi, dikerjakan, selesai, batal }

class StatusBadge {
  final String label;
  final Color bg;
  final Color fg;

  const StatusBadge({required this.label, required this.bg, required this.fg});
}

extension ServiceStatusX on ServiceStatus {
  StatusBadge get badge {
    switch (this) {
      case ServiceStatus.menunggu:
        return const StatusBadge(
          label: 'Menunggu',
          bg: AppColors.menungguBg,
          fg: AppColors.menungguFg,
        );
      case ServiceStatus.dikonfirmasi:
        return const StatusBadge(
          label: 'Dikonfirmasi',
          bg: AppColors.dikonfirmasiBg,
          fg: AppColors.dikonfirmasiFg,
        );
      case ServiceStatus.dikerjakan:
        return const StatusBadge(
          label: 'Dikerjakan',
          bg: AppColors.dikerjakanBg,
          fg: AppColors.dikerjakanFg,
        );
      case ServiceStatus.selesai:
        return const StatusBadge(
          label: 'Selesai',
          bg: AppColors.selesaiBg,
          fg: AppColors.selesaiFg,
        );
      case ServiceStatus.batal:
        return const StatusBadge(
          label: 'Dibatalkan',
          bg: AppColors.batalBg,
          fg: AppColors.batalFg,
        );
    }
  }

  /// Position in the 4-step happy-path timeline (menunggu..selesai). -1 for 'batal'.
  int get timelineIndex {
    const order = [
      ServiceStatus.menunggu,
      ServiceStatus.dikonfirmasi,
      ServiceStatus.dikerjakan,
      ServiceStatus.selesai,
    ];
    return order.indexOf(this);
  }

  ServiceStatus? get nextStatus {
    switch (this) {
      case ServiceStatus.menunggu:
        return ServiceStatus.dikonfirmasi;
      case ServiceStatus.dikonfirmasi:
        return ServiceStatus.dikerjakan;
      case ServiceStatus.dikerjakan:
        return ServiceStatus.selesai;
      case ServiceStatus.selesai:
      case ServiceStatus.batal:
        return null;
    }
  }

  String get advanceActionLabel {
    switch (this) {
      case ServiceStatus.menunggu:
        return 'Konfirmasi Pesanan';
      case ServiceStatus.dikonfirmasi:
        return 'Mulai Dikerjakan';
      case ServiceStatus.dikerjakan:
        return 'Tandai Selesai';
      case ServiceStatus.selesai:
      case ServiceStatus.batal:
        return '';
    }
  }
}

class TimelineStep {
  final String label;
  final bool done;
  final bool isLast;
  final String num;

  const TimelineStep({
    required this.label,
    required this.done,
    required this.isLast,
    required this.num,
  });
}

List<TimelineStep> buildTimeline(ServiceStatus status) {
  const labels = ['Diajukan', 'Dikonfirmasi', 'Dikerjakan', 'Selesai'];
  final idx = status.timelineIndex;
  return List.generate(labels.length, (i) {
    final done = i <= idx;
    return TimelineStep(
      label: labels[i],
      done: done,
      isLast: i == labels.length - 1,
      num: done ? '✓' : '${i + 1}',
    );
  });
}

class ServiceItem {
  final String nama;
  final int qty;
  final int harga;

  const ServiceItem({
    required this.nama,
    required this.qty,
    required this.harga,
  });

  int get subtotal => qty * harga;

  Map<String, dynamic> toJson() => {'nama': nama, 'qty': qty, 'harga': harga};

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
    nama: json['nama'] as String,
    qty: json['qty'] as int,
    harga: json['harga'] as int,
  );
}

class ServiceRequest {
  final String id;
  final String customer;
  final bool mine;
  final String? vehId;
  final String vehLabel;
  final String bengkelId;
  final DateTime tanggal;
  final String jam;
  final String jenis;
  final ServiceStatus status;
  final String keluhan;
  final int biaya;
  final List<ServiceItem> items;
  final String saran;
  final String saranBulan;
  final int rating;

  const ServiceRequest({
    required this.id,
    required this.customer,
    required this.mine,
    this.vehId,
    required this.vehLabel,
    required this.bengkelId,
    required this.tanggal,
    required this.jam,
    required this.jenis,
    required this.status,
    required this.keluhan,
    required this.biaya,
    this.items = const [],
    this.saran = '',
    this.saranBulan = '',
    this.rating = 0,
  });

  ServiceRequest copyWith({
    ServiceStatus? status,
    String? saran,
    String? saranBulan,
    List<ServiceItem>? items,
    int? biaya,
    int? rating,
  }) {
    return ServiceRequest(
      id: id,
      customer: customer,
      mine: mine,
      vehId: vehId,
      vehLabel: vehLabel,
      bengkelId: bengkelId,
      tanggal: tanggal,
      jam: jam,
      jenis: jenis,
      status: status ?? this.status,
      keluhan: keluhan,
      biaya: biaya ?? this.biaya,
      items: items ?? this.items,
      saran: saran ?? this.saran,
      saranBulan: saranBulan ?? this.saranBulan,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer': customer,
    'mine': mine,
    'vehId': vehId,
    'vehLabel': vehLabel,
    'bengkelId': bengkelId,
    'tanggal': tanggal.toIso8601String(),
    'jam': jam,
    'jenis': jenis,
    'status': status.name,
    'keluhan': keluhan,
    'biaya': biaya,
    'items': items.map((i) => i.toJson()).toList(),
    'saran': saran,
    'saranBulan': saranBulan,
    'rating': rating,
  };

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
    id: json['id'] as String,
    customer: json['customer'] as String,
    mine: json['mine'] as bool,
    vehId: json['vehId'] as String?,
    vehLabel: json['vehLabel'] as String,
    bengkelId: json['bengkelId'] as String,
    tanggal: DateTime.parse(json['tanggal'] as String),
    jam: json['jam'] as String,
    jenis: json['jenis'] as String,
    status: ServiceStatus.values.byName(json['status'] as String),
    keluhan: json['keluhan'] as String,
    biaya: json['biaya'] as int,
    items: (json['items'] as List)
        .map((i) => ServiceItem.fromJson(i as Map<String, dynamic>))
        .toList(),
    saran: json['saran'] as String,
    saranBulan: json['saranBulan'] as String,
    rating: json['rating'] as int? ?? 0,
  );
}
