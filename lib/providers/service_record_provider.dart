import 'package:flutter/foundation.dart';

import '../models/service_record.dart';
import '../services/service_record_service.dart';

class ServiceRecordProvider extends ChangeNotifier {
  final ServiceRecordService _service = ServiceRecordService();

  final Map<int, List<ServiceRecord>> _byVehicle = {};
  bool _loading = false;

  bool get loading => _loading;

  List<ServiceRecord> forVehicle(int vehicleId) => _byVehicle[vehicleId] ?? [];

  Future<void> loadForVehicle(int vehicleId) async {
    _loading = true;
    notifyListeners();
    _byVehicle[vehicleId] = await _service.getByVehicle(vehicleId);
    _loading = false;
    notifyListeners();
  }

  Future<void> add(ServiceRecord record) async {
    await _service.insert(record);
    await loadForVehicle(record.vehicleId);
  }

  Future<void> update(ServiceRecord record) async {
    await _service.update(record);
    await loadForVehicle(record.vehicleId);
  }

  Future<void> delete(int id, int vehicleId) async {
    await _service.delete(id);
    await loadForVehicle(vehicleId);
  }
}
