import 'package:flutter/foundation.dart';

import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService _service = VehicleService();

  List<Vehicle> _vehicles = [];
  bool _loading = false;

  List<Vehicle> get vehicles => _vehicles;
  bool get loading => _loading;

  List<Vehicle> byCustomer(int customerId) =>
      _vehicles.where((v) => v.customerId == customerId).toList();

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _vehicles = await _service.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Vehicle vehicle) async {
    await _service.insert(vehicle);
    await load();
  }

  Future<void> update(Vehicle vehicle) async {
    await _service.update(vehicle);
    await load();
  }

  Future<void> delete(int id) async {
    await _service.delete(id);
    await load();
  }

  Future<void> bumpOdometerIfHigher(int vehicleId, int odometer) async {
    await _service.updateOdometerIfHigher(vehicleId, odometer);
    await load();
  }

  Vehicle? byId(int id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
}
