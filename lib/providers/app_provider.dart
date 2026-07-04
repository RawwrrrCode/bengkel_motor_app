import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/seed_data.dart';
import '../models/bengkel.dart';
import '../models/jasa.dart';
import '../models/service_request.dart';
import '../models/sparepart.dart';
import '../models/vehicle.dart';

enum UserRole { user, bengkel }

const currentBengkelId = 'b1';
const currentCustomerName = 'Andi Pratama';

const _prefsKey = 'bengkelku_state_v1';

class AppProvider extends ChangeNotifier {
  UserRole _role = UserRole.user;
  bool _roleChosen = false;
  final List<Vehicle> _vehicles = seedVehicles();
  final List<Bengkel> _bengkels = seedBengkels();
  final List<Sparepart> _spareparts = seedSpareparts();
  final List<Jasa> _jasaList = seedJasa();
  final List<ServiceRequest> _serviceRequests = seedServiceRequests();

  /// Loads any previously-saved state, replacing the seed defaults if found.
  /// Vehicles are never mutated so they're always left as seeded. Call once
  /// at startup, before the app is shown, so there's no flash of seed data.
  Future<void> loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final json = jsonDecode(raw) as Map<String, dynamic>;

      _role = UserRole.values.byName(json['role'] as String);
      _roleChosen = json['roleChosen'] as bool;
      _spareparts
        ..clear()
        ..addAll(
          (json['spareparts'] as List).map(
            (e) => Sparepart.fromJson(e as Map<String, dynamic>),
          ),
        );
      if (json['jasaList'] != null) {
        _jasaList
          ..clear()
          ..addAll(
            (json['jasaList'] as List).map(
              (e) => Jasa.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
      if (json['bengkels'] != null) {
        _bengkels
          ..clear()
          ..addAll(
            (json['bengkels'] as List).map(
              (e) => Bengkel.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
      _serviceRequests
        ..clear()
        ..addAll(
          (json['serviceRequests'] as List).map(
            (e) => ServiceRequest.fromJson(e as Map<String, dynamic>),
          ),
        );
      notifyListeners();
    } catch (_) {
      // Corrupted/old-schema save data — keep the fresh seed defaults.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = {
      'role': _role.name,
      'roleChosen': _roleChosen,
      'spareparts': _spareparts.map((p) => p.toJson()).toList(),
      'jasaList': _jasaList.map((j) => j.toJson()).toList(),
      'bengkels': _bengkels.map((b) => b.toJson()).toList(),
      'serviceRequests': _serviceRequests.map((s) => s.toJson()).toList(),
    };
    await prefs.setString(_prefsKey, jsonEncode(json));
  }

  UserRole get role => _role;
  bool get roleChosen => _roleChosen;
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<Bengkel> get bengkels => List.unmodifiable(_bengkels);
  List<Sparepart> get spareparts => List.unmodifiable(_spareparts);
  List<Jasa> get jasaList => List.unmodifiable(_jasaList);
  List<ServiceRequest> get serviceRequests =>
      List.unmodifiable(_serviceRequests);

  /// Used by the initial role-selection screen.
  void chooseRole(UserRole role) {
    _role = role;
    _roleChosen = true;
    notifyListeners();
    _persist();
  }

  /// Used by the small "Ganti Peran" quick-switch affordance once inside the app.
  void setRole(UserRole role) {
    if (_role == role) return;
    _role = role;
    notifyListeners();
    _persist();
  }

  Vehicle? vehicleById(String? id) {
    if (id == null) return null;
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  Bengkel? bengkelById(String? id) {
    if (id == null) return null;
    try {
      return _bengkels.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  ServiceRequest? serviceById(String? id) {
    if (id == null) return null;
    try {
      return _serviceRequests.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ServiceRequest> get myServices =>
      _serviceRequests.where((s) => s.mine).toList();

  ServiceRequest? get activeMyService {
    try {
      return myServices.firstWhere(
        (s) =>
            s.status != ServiceStatus.selesai &&
            s.status != ServiceStatus.batal,
      );
    } catch (_) {
      return null;
    }
  }

  List<ServiceRequest> servicesForBengkel(String bengkelId) =>
      _serviceRequests.where((s) => s.bengkelId == bengkelId).toList();

  /// Whether [bengkelId] already has an active (non-cancelled) booking at
  /// [jam] on [tanggal] — used to stop the booking flow from double-booking
  /// the same slot.
  bool isSlotTaken(String bengkelId, DateTime tanggal, String jam) {
    return _serviceRequests.any(
      (s) =>
          s.bengkelId == bengkelId &&
          s.status != ServiceStatus.batal &&
          s.jam == jam &&
          s.tanggal.year == tanggal.year &&
          s.tanggal.month == tanggal.month &&
          s.tanggal.day == tanggal.day,
    );
  }

  String submitServiceRequest({
    required String vehId,
    required String bengkelId,
    required String jenis,
    required DateTime tanggal,
    required String jam,
    required String keluhan,
  }) {
    final vehicle = vehicleById(vehId);
    final id = 'SVC-${2080 + (DateTime.now().microsecond % 90)}';
    final request = ServiceRequest(
      id: id,
      customer: currentCustomerName,
      mine: true,
      vehId: vehId,
      vehLabel: vehicle != null ? '${vehicle.nama} · ${vehicle.plat}' : '',
      bengkelId: bengkelId,
      tanggal: tanggal,
      jam: jam,
      jenis: jenis,
      status: ServiceStatus.menunggu,
      keluhan: keluhan.isEmpty ? '-' : keluhan,
      biaya: 0,
    );
    _serviceRequests.insert(0, request);
    notifyListeners();
    _persist();
    return id;
  }

  void advanceStatus(String id) {
    final index = _serviceRequests.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final current = _serviceRequests[index];
    final next = current.status.nextStatus;
    if (next == null) return;
    _serviceRequests[index] = current.copyWith(status: next);
    notifyListeners();
    _persist();
  }

  /// Advances a 'dikerjakan' request straight to 'selesai', recording the
  /// itemized cost breakdown the bengkel entered (biaya is derived from items).
  /// [stockDeductions] maps sparepart id -> qty used, so stock picked in the
  /// rincian biaya picker is deducted from the sparepart catalog.
  void completeService(
    String id,
    List<ServiceItem> items, {
    Map<String, int> stockDeductions = const {},
  }) {
    final index = _serviceRequests.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final biaya = items.fold<int>(0, (a, i) => a + i.subtotal);
    _serviceRequests[index] = _serviceRequests[index].copyWith(
      status: ServiceStatus.selesai,
      items: items,
      biaya: biaya,
    );
    for (final entry in stockDeductions.entries) {
      final sIndex = _spareparts.indexWhere((s) => s.id == entry.key);
      if (sIndex == -1) continue;
      final current = _spareparts[sIndex];
      final newStok = current.stok - entry.value;
      _spareparts[sIndex] = current.copyWith(stok: newStok < 0 ? 0 : newStok);
    }
    notifyListeners();
    _persist();
  }

  void rejectRequest(String id) {
    final index = _serviceRequests.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _serviceRequests[index] = _serviceRequests[index].copyWith(
      status: ServiceStatus.batal,
    );
    notifyListeners();
    _persist();
  }

  void saveSaran(
    String id, {
    required String saran,
    required String saranBulan,
  }) {
    final index = _serviceRequests.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final current = _serviceRequests[index];
    _serviceRequests[index] = current.copyWith(
      saran: saran,
      saranBulan: saranBulan.isEmpty ? current.saranBulan : saranBulan,
    );
    notifyListeners();
    _persist();
  }

  /// Records the customer's 1-5 star rating for a completed service and
  /// folds it into the bengkel's average rating. A service can only be
  /// rated once (rating stays 0 until then).
  void rateService(String id, int rating) {
    final index = _serviceRequests.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final svc = _serviceRequests[index];
    if (svc.rating != 0 || rating < 1 || rating > 5) return;
    _serviceRequests[index] = svc.copyWith(rating: rating);

    final bIndex = _bengkels.indexWhere((b) => b.id == svc.bengkelId);
    if (bIndex != -1) {
      final bengkel = _bengkels[bIndex];
      final newUlasan = bengkel.ulasan + 1;
      final newRating =
          ((bengkel.rating * bengkel.ulasan) + rating) / newUlasan;
      _bengkels[bIndex] = bengkel.copyWith(
        rating: newRating,
        ulasan: newUlasan,
      );
    }
    notifyListeners();
    _persist();
  }

  String _nextId(String prefix, Iterable<String> existingIds) {
    var n = existingIds.length + 1;
    while (existingIds.contains('$prefix$n')) {
      n++;
    }
    return '$prefix$n';
  }

  void addSparepart({
    required String nama,
    required int harga,
    required int stok,
  }) {
    if (nama.isEmpty) return;
    final id = _nextId('p', _spareparts.map((s) => s.id));
    _spareparts.add(
      Sparepart(id: id, nama: nama, kategori: 'Umum', harga: harga, stok: stok),
    );
    notifyListeners();
    _persist();
  }

  void updateSparepart(
    String id, {
    required String nama,
    required int harga,
    required int stok,
  }) {
    final index = _spareparts.indexWhere((s) => s.id == id);
    if (index == -1 || nama.isEmpty) return;
    _spareparts[index] = _spareparts[index].copyWith(
      nama: nama,
      harga: harga,
      stok: stok,
    );
    notifyListeners();
    _persist();
  }

  void deleteSparepart(String id) {
    _spareparts.removeWhere((s) => s.id == id);
    notifyListeners();
    _persist();
  }

  void addJasa({required String nama, required int harga}) {
    if (nama.isEmpty) return;
    final id = _nextId('j', _jasaList.map((j) => j.id));
    _jasaList.add(Jasa(id: id, nama: nama, harga: harga));
    notifyListeners();
    _persist();
  }

  void updateJasa(String id, {required String nama, required int harga}) {
    final index = _jasaList.indexWhere((j) => j.id == id);
    if (index == -1 || nama.isEmpty) return;
    _jasaList[index] = Jasa(id: id, nama: nama, harga: harga);
    notifyListeners();
    _persist();
  }

  void deleteJasa(String id) {
    _jasaList.removeWhere((j) => j.id == id);
    notifyListeners();
    _persist();
  }
}
