import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/customer_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/service_record_provider.dart';
import 'providers/vehicle_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';

final routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(BengkelMotorApp(notificationService: notificationService));
}

class BengkelMotorApp extends StatelessWidget {
  final NotificationService notificationService;

  const BengkelMotorApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => ServiceRecordProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider(notificationService)),
      ],
      child: MaterialApp(
        title: 'Bengkel Motor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        navigatorObservers: [routeObserver],
        home: const DashboardScreen(),
      ),
    );
  }
}
