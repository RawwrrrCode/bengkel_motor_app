import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../database/seed_data.dart';
import '../models/app_user.dart';
import '../models/bengkel.dart';
import '../models/jasa.dart';
import '../models/service_request.dart';
import '../models/sparepart.dart';
import '../models/vehicle.dart';

export '../models/app_user.dart' show UserRole;

class AppProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _vehiclesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bengkelsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _myRequestsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bengkelRequestsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sparepartsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _jasaSub;

  User? _firebaseUser;
  AppUser? _profile;
  bool _profileFetching = false;

  List<Vehicle> _vehicles = [];
  List<Bengkel> _bengkels = [];
  List<Sparepart> _spareparts = [];
  List<Jasa> _jasaList = [];
  List<ServiceRequest> _myRequests = [];
  List<ServiceRequest> _bengkelRequests = [];

  AppProvider() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    _firebaseUser = user;
    _profileSub?.cancel();
    _clearRoleScoped();
    _profile = null;
    _vehiclesSub?.cancel();

    if (user == null) {
      _profileFetching = false;
      _vehicles = [];
      notifyListeners();
      return;
    }

    _profileFetching = true;

    _vehiclesSub = _db
        .collection('vehicles')
        .where('ownerUid', isEqualTo: user.uid)
        .snapshots()
        .listen((snap) {
          _vehicles = snap.docs
              .map((d) => Vehicle.fromJson(d.id, d.data()))
              .toList();
          notifyListeners();
        });

    _bengkelsSub = _db.collection('bengkels').snapshots().listen((snap) {
      _bengkels = snap.docs
          .map((d) => Bengkel.fromJson(d.id, d.data()))
          .toList();
      notifyListeners();
    });

    _myRequestsSub = _db
        .collection('serviceRequests')
        .where('customerUid', isEqualTo: user.uid)
        .snapshots()
        .listen((snap) {
          _myRequests =
              snap.docs
                  .map((d) => ServiceRequest.fromJson(d.id, d.data()))
                  .toList()
                ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
          notifyListeners();
        });

    _profileSub = _db.collection('users').doc(user.uid).snapshots().listen((
      snap,
    ) {
      final data = snap.data();
      final newProfile = data == null
          ? null
          : AppUser.fromJson(user.uid, data);
      final oldBengkelId = _profile?.bengkelId;
      _profile = newProfile;
      _profileFetching = false;
      if (newProfile?.bengkelId != oldBengkelId) {
        _resubscribeBengkelScoped(newProfile?.bengkelId);
      }
      notifyListeners();
    });

    notifyListeners();
  }

  void _clearRoleScoped() {
    _bengkelsSub?.cancel();
    _myRequestsSub?.cancel();
    _bengkelRequestsSub?.cancel();
    _sparepartsSub?.cancel();
    _jasaSub?.cancel();
    _bengkels = [];
    _myRequests = [];
    _bengkelRequests = [];
    _spareparts = [];
    _jasaList = [];
  }

  void _resubscribeBengkelScoped(String? bengkelId) {
    _bengkelRequestsSub?.cancel();
    _sparepartsSub?.cancel();
    _jasaSub?.cancel();

    if (bengkelId == null) {
      _bengkelRequests = [];
      _spareparts = [];
      _jasaList = [];
      notifyListeners();
      return;
    }

    _bengkelRequestsSub = _db
        .collection('serviceRequests')
        .where('bengkelId', isEqualTo: bengkelId)
        .snapshots()
        .listen((snap) {
          _bengkelRequests =
              snap.docs
                  .map((d) => ServiceRequest.fromJson(d.id, d.data()))
                  .toList()
                ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
          notifyListeners();
        });

    _sparepartsSub = _db
        .collection('bengkels')
        .doc(bengkelId)
        .collection('spareparts')
        .snapshots()
        .listen((snap) {
          _spareparts = snap.docs
              .map((d) => Sparepart.fromJson(d.id, d.data()))
              .toList();
          notifyListeners();
        });

    _jasaSub = _db
        .collection('bengkels')
        .doc(bengkelId)
        .collection('jasa')
        .snapshots()
        .listen((snap) {
          _jasaList = snap.docs
              .map((d) => Jasa.fromJson(d.id, d.data()))
              .toList();
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    _vehiclesSub?.cancel();
    _bengkelsSub?.cancel();
    _myRequestsSub?.cancel();
    _bengkelRequestsSub?.cancel();
    _sparepartsSub?.cancel();
    _jasaSub?.cancel();
    super.dispose();
  }

  // ---- Auth & profile ----

  bool get isLoggedIn => _firebaseUser != null;
  String? get myUid => _firebaseUser?.uid;
  bool get profileLoading => isLoggedIn && _profileFetching;
  AppUser? get profile => _profile;
  UserRole get role => _profile?.activeRole ?? UserRole.user;
  String? get myBengkelId => _profile?.bengkelId;
  Bengkel? get myBengkel => bengkelById(myBengkelId);
  String get displayName => _profile?.displayName ?? '';

  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      await _db
          .collection('users')
          .doc(uid)
          .set(
            AppUser(
              uid: uid,
              email: email,
              displayName: displayName,
              activeRole: role,
            ).toJson(),
          );
      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    }
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password minimal 6 karakter.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      default:
        return e.message ?? 'Terjadi kesalahan. Coba lagi.';
    }
  }

  /// Onboarding for a first-time bengkel owner: creates their `bengkels` doc
  /// and seeds a starter sparepart/jasa catalog so they don't start empty.
  Future<void> completeBengkelSetup({
    required String nama,
    required String alamat,
    required String jam,
    required String spesialis,
  }) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return;
    final bengkelRef = _db.collection('bengkels').doc();
    // The bengkel doc must exist before the security rules' `ownsBengkel()`
    // check (which reads it back via `get()`) can authorize writes to its
    // spareparts/jasa subcollections — so this can't all be one batch.
    await bengkelRef.set(
      Bengkel(
        id: bengkelRef.id,
        ownerUid: uid,
        nama: nama,
        alamat: alamat,
        rating: 0,
        ulasan: 0,
        jarak: '-',
        jam: jam,
        buka: true,
        spesialis: spesialis,
        verified: false,
      ).toJson(),
    );
    final batch = _db.batch();
    for (final p in seedSpareparts()) {
      batch.set(bengkelRef.collection('spareparts').doc(), p.toJson());
    }
    for (final j in seedJasa()) {
      batch.set(bengkelRef.collection('jasa').doc(), j.toJson());
    }
    batch.update(_db.collection('users').doc(uid), {
      'bengkelId': bengkelRef.id,
    });
    await batch.commit();
  }

  // ---- Data getters ----

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<Bengkel> get bengkels => List.unmodifiable(_bengkels);
  List<Sparepart> get spareparts => List.unmodifiable(_spareparts);
  List<Jasa> get jasaList => List.unmodifiable(_jasaList);

  /// Merges the two categories of `serviceRequests` this account is allowed
  /// to read under the security rules: ones this uid filed as a customer,
  /// and (if this uid owns a bengkel) ones filed against that bengkel.
  List<ServiceRequest> get serviceRequests {
    final map = <String, ServiceRequest>{};
    for (final s in _bengkelRequests) {
      map[s.id] = s;
    }
    for (final s in _myRequests) {
      map[s.id] = s;
    }
    final list = map.values.toList()
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return List.unmodifiable(list);
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
      return serviceRequests.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ServiceRequest> get myServices => List.unmodifiable(_myRequests);

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
      _bengkelRequests.where((s) => s.bengkelId == bengkelId).toList();

  /// One-shot read of another bengkel's public catalog (e.g. for a customer
  /// browsing `BengkelDetailScreen`) — not live-streamed like [spareparts],
  /// since that getter only tracks the signed-in bengkel owner's own catalog.
  Future<List<Sparepart>> fetchSparepartsFor(String bengkelId) async {
    final snap = await _db
        .collection('bengkels')
        .doc(bengkelId)
        .collection('spareparts')
        .get();
    return snap.docs.map((d) => Sparepart.fromJson(d.id, d.data())).toList();
  }

  /// Whether [bengkelId] already has an active (non-cancelled) booking at
  /// [jam] on [tanggal] — used to stop the booking flow from double-booking
  /// the same slot. Best-effort: only sees requests this account is allowed
  /// to read (its own bookings, plus its own bengkel's if it owns one), so
  /// conflicts between two other customers at a bengkel this account doesn't
  /// own aren't visible here.
  bool isSlotTaken(String bengkelId, DateTime tanggal, String jam) {
    return serviceRequests.any(
      (s) =>
          s.bengkelId == bengkelId &&
          s.status != ServiceStatus.batal &&
          s.jam == jam &&
          s.tanggal.year == tanggal.year &&
          s.tanggal.month == tanggal.month &&
          s.tanggal.day == tanggal.day,
    );
  }

  Future<String> submitServiceRequest({
    required String vehId,
    required String bengkelId,
    required String jenis,
    required DateTime tanggal,
    required String jam,
    required String keluhan,
  }) async {
    final uid = _firebaseUser!.uid;
    final vehicle = vehicleById(vehId);
    final id = 'SVC-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final request = ServiceRequest(
      id: id,
      customer: displayName,
      customerUid: uid,
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
    await _db.collection('serviceRequests').doc(id).set(request.toJson());
    return id;
  }

  Future<void> advanceStatus(String id) async {
    final current = serviceById(id);
    if (current == null) return;
    final next = current.status.nextStatus;
    if (next == null) return;
    await _db.collection('serviceRequests').doc(id).update({
      'status': next.name,
    });
  }

  /// Advances a 'dikerjakan' request straight to 'selesai', recording the
  /// itemized cost breakdown the bengkel entered (biaya is derived from items).
  /// [stockDeductions] maps sparepart id -> qty used, so stock picked in the
  /// rincian biaya picker is deducted from the sparepart catalog.
  Future<void> completeService(
    String id,
    List<ServiceItem> items, {
    Map<String, int> stockDeductions = const {},
  }) async {
    final biaya = items.fold<int>(0, (a, i) => a + i.subtotal);
    final batch = _db.batch();
    batch.update(_db.collection('serviceRequests').doc(id), {
      'status': ServiceStatus.selesai.name,
      'items': items.map((i) => i.toJson()).toList(),
      'biaya': biaya,
    });
    final bengkelId = myBengkelId;
    if (bengkelId != null) {
      final sparepartsRef = _db
          .collection('bengkels')
          .doc(bengkelId)
          .collection('spareparts');
      for (final entry in stockDeductions.entries) {
        Sparepart? sparepart;
        for (final s in _spareparts) {
          if (s.id == entry.key) {
            sparepart = s;
            break;
          }
        }
        if (sparepart == null) continue;
        final newStok = sparepart.stok - entry.value;
        batch.update(sparepartsRef.doc(entry.key), {
          'stok': newStok < 0 ? 0 : newStok,
        });
      }
    }
    await batch.commit();
  }

  /// Used by the bengkel side to reject an incoming request, optionally
  /// recording why so the customer can see it in their histori.
  Future<void> rejectRequest(String id, {String alasan = ''}) async {
    await _db.collection('serviceRequests').doc(id).update({
      'status': ServiceStatus.batal.name,
      'alasanBatal': alasan.isEmpty ? 'Ditolak oleh bengkel' : alasan,
    });
  }

  /// Used by the customer to cancel their own still-pending request. Only
  /// allowed before the bengkel has started working on it.
  Future<void> cancelRequest(String id) async {
    final current = serviceById(id);
    if (current == null) return;
    if (current.status != ServiceStatus.menunggu &&
        current.status != ServiceStatus.dikonfirmasi) {
      return;
    }
    await _db.collection('serviceRequests').doc(id).update({
      'status': ServiceStatus.batal.name,
      'alasanBatal': 'Dibatalkan oleh pelanggan',
    });
  }

  Future<void> saveSaran(
    String id, {
    required String saran,
    required String saranBulan,
  }) async {
    final current = serviceById(id);
    if (current == null) return;
    await _db.collection('serviceRequests').doc(id).update({
      'saran': saran,
      'saranBulan': saranBulan.isEmpty ? current.saranBulan : saranBulan,
    });
  }

  /// Records the customer's 1-5 star rating for a completed service and
  /// folds it into the bengkel's average rating. A service can only be
  /// rated once (rating stays 0 until then).
  Future<void> rateService(String id, int rating) async {
    final svc = serviceById(id);
    if (svc == null || svc.rating != 0 || rating < 1 || rating > 5) return;
    final batch = _db.batch();
    batch.update(_db.collection('serviceRequests').doc(id), {
      'rating': rating,
    });
    final bengkel = bengkelById(svc.bengkelId);
    if (bengkel != null) {
      final newUlasan = bengkel.ulasan + 1;
      final newRating =
          ((bengkel.rating * bengkel.ulasan) + rating) / newUlasan;
      batch.update(_db.collection('bengkels').doc(bengkel.id), {
        'rating': newRating,
        'ulasan': newUlasan,
      });
    }
    await batch.commit();
  }

  Future<void> addSparepart({
    required String nama,
    required int harga,
    required int stok,
  }) async {
    final bengkelId = myBengkelId;
    if (nama.isEmpty || bengkelId == null) return;
    final ref = _db
        .collection('bengkels')
        .doc(bengkelId)
        .collection('spareparts')
        .doc();
    await ref.set(
      Sparepart(
        id: ref.id,
        nama: nama,
        kategori: 'Umum',
        harga: harga,
        stok: stok,
      ).toJson(),
    );
  }

  Future<void> updateSparepart(
    String id, {
    required String nama,
    required int harga,
    required int stok,
  }) async {
    final bengkelId = myBengkelId;
    if (nama.isEmpty || bengkelId == null) return;
    await _db
        .collection('bengkels')
        .doc(bengkelId)
        .collection('spareparts')
        .doc(id)
        .update({'nama': nama, 'harga': harga, 'stok': stok});
  }

  Future<void> deleteSparepart(String id) async {
    final bengkelId = myBengkelId;
    if (bengkelId == null) return;
    await _db
        .collection('bengkels')
        .doc(bengkelId)
        .collection('spareparts')
        .doc(id)
        .delete();
  }

  Future<void> addJasa({required String nama, required int harga}) async {
    final bengkelId = myBengkelId;
    if (nama.isEmpty || bengkelId == null) return;
    final ref = _db
        .collection('bengkels')
        .doc(bengkelId)
        .collection('jasa')
        .doc();
    await ref.set(Jasa(id: ref.id, nama: nama, harga: harga).toJson());
  }

  Future<void> updateJasa(
    String id, {
    required String nama,
    required int harga,
  }) async {
    final bengkelId = myBengkelId;
    if (nama.isEmpty || bengkelId == null) return;
    await _db
        .collection('bengkels')
        .doc(bengkelId)
        .collection('jasa')
        .doc(id)
        .update({'nama': nama, 'harga': harga});
  }

  Future<void> deleteJasa(String id) async {
    final bengkelId = myBengkelId;
    if (bengkelId == null) return;
    await _db
        .collection('bengkels')
        .doc(bengkelId)
        .collection('jasa')
        .doc(id)
        .delete();
  }

  /// Adds a new vehicle with no maintenance schedule yet — the user can
  /// still book service for it, it just won't show up under "Perawatan
  /// Perlu Dicek" until maintenance history exists.
  Future<void> addVehicle({
    required String nama,
    required String merk,
    required String plat,
    required int tahun,
    required String warna,
    required String tipe,
    required int cc,
    required int km,
  }) async {
    final uid = _firebaseUser?.uid;
    if (nama.isEmpty || plat.isEmpty || uid == null) return;
    final ref = _db.collection('vehicles').doc();
    await ref.set(
      Vehicle(
        id: ref.id,
        ownerUid: uid,
        nama: nama,
        merk: merk,
        plat: plat,
        tahun: tahun,
        warna: warna,
        tipe: tipe,
        cc: cc,
        km: km,
        maint: const [],
      ).toJson(),
    );
  }
}
