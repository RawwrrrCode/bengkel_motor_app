import 'package:flutter/foundation.dart';

import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _service = CustomerService();

  List<Customer> _customers = [];
  bool _loading = false;

  List<Customer> get customers => _customers;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _customers = await _service.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Customer customer) async {
    await _service.insert(customer);
    await load();
  }

  Future<void> update(Customer customer) async {
    await _service.update(customer);
    await load();
  }

  Future<void> delete(int id) async {
    await _service.delete(id);
    await load();
  }

  Customer? byId(int id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
