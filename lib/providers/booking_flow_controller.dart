import 'package:flutter/foundation.dart';

import 'app_provider.dart';

const jenisLayananList = [
  'Servis Rutin',
  'Servis Rutin + Ganti Oli',
  'Ganti Sparepart',
  'Perbaikan / Keluhan',
  'Servis CVT',
];

const jamSlotList = ['09.00', '10.00', '11.00', '13.00', '14.00', '15.00'];

class BookingFlowController extends ChangeNotifier {
  BookingFlowController({String? initialVehId, String? initialBengkelId})
      : vehId = initialVehId,
        bengkelId = initialBengkelId ?? currentBengkelId;

  int step = 1;
  String? vehId;
  String bengkelId;
  String jenis = jenisLayananList.first;
  DateTime tanggal = DateTime.now().add(const Duration(days: 1));
  String jam = jamSlotList.first;
  String keluhan = '';
  String? newId;

  void setVehicle(String id) {
    vehId = id;
    notifyListeners();
  }

  void setBengkel(String id) {
    bengkelId = id;
    notifyListeners();
  }

  void setJenis(String value) {
    jenis = value;
    notifyListeners();
  }

  void setTanggal(DateTime value) {
    tanggal = value;
    notifyListeners();
  }

  void setJam(String value) {
    jam = value;
    notifyListeners();
  }

  void setKeluhan(String value) {
    keluhan = value;
    notifyListeners();
  }

  void next() {
    if (step < 3) {
      step++;
      notifyListeners();
    }
  }

  /// Returns true if the step was decremented, false if already at step 1
  /// (caller should pop the booking route in that case).
  bool prev() {
    if (step > 1) {
      step--;
      notifyListeners();
      return true;
    }
    return false;
  }

  void submit(AppProvider appProvider) {
    if (vehId == null) return;
    newId = appProvider.submitServiceRequest(
      vehId: vehId!,
      bengkelId: bengkelId,
      jenis: jenis,
      tanggal: tanggal,
      jam: jam,
      keluhan: keluhan,
    );
    step = 4;
    notifyListeners();
  }
}
