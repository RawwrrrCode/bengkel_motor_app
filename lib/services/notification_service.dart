import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/constants.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(settings: initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> showDueSummary({
    required int overdueCount,
    required int dueSoonCount,
  }) async {
    if (overdueCount == 0 && dueSoonCount == 0) return;

    final parts = <String>[];
    if (overdueCount > 0) parts.add('$overdueCount kendaraan sudah lewat jadwal servis');
    if (dueSoonCount > 0) parts.add('$dueSoonCount kendaraan akan segera perlu servis');
    final body = parts.join(', ');

    const androidDetails = AndroidNotificationDetails(
      'service_reminders',
      'Pengingat Servis',
      channelDescription: 'Notifikasi kendaraan yang perlu diservis',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: AppConstants.summaryNotificationId,
      title: 'Pengingat Servis Bengkel',
      body: body,
      notificationDetails: details,
    );
  }
}
