import 'package:flutter/foundation.dart';

import '../services/notification_service.dart';
import '../services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _service = ReminderService();
  final NotificationService _notificationService;

  ReminderProvider(this._notificationService);

  List<VehicleDueInfo> _dueList = [];
  bool _loading = false;
  DateTime? _lastNotifiedDay;

  List<VehicleDueInfo> get dueList => _dueList;
  bool get loading => _loading;

  int get overdueCount =>
      _dueList.where((v) => v.status == DueStatus.overdue).length;
  int get dueSoonCount =>
      _dueList.where((v) => v.status == DueStatus.dueSoon).length;

  Future<void> load({bool notify = false}) async {
    _loading = true;
    notifyListeners();
    _dueList = await _service.getVehiclesNeedingService();
    _loading = false;
    notifyListeners();

    if (notify) {
      await _maybeNotify();
    }
  }

  Future<void> _maybeNotify() async {
    final today = DateTime.now();
    final alreadyNotifiedToday = _lastNotifiedDay != null &&
        _lastNotifiedDay!.year == today.year &&
        _lastNotifiedDay!.month == today.month &&
        _lastNotifiedDay!.day == today.day;

    if (alreadyNotifiedToday) return;
    if (overdueCount == 0 && dueSoonCount == 0) return;

    await _notificationService.showDueSummary(
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
    );
    _lastNotifiedDay = today;
  }
}
