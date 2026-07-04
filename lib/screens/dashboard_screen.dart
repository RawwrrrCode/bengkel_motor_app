import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/reminder_provider.dart';
import '../widgets/due_badge.dart';
import '../widgets/vehicle_card.dart';
import '../utils/date_utils.dart';
import 'customer_list_screen.dart';
import 'vehicle_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().load(notify: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<ReminderProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bengkel Motor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Pelanggan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerListScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ReminderProvider>().load(),
        child: Consumer<ReminderProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.dueList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.dueList.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Tidak ada kendaraan yang perlu diservis saat ini.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${provider.overdueCount} terlambat • ${provider.dueSoonCount} segera',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...provider.dueList.map((info) {
                  return VehicleCard(
                    vehicle: info.vehicle,
                    subtitle:
                        '${info.customerName} • jatuh tempo ${AppDateUtils.formatDisplay(info.dueDate)}',
                    trailing: DueBadge(status: info.status),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VehicleDetailScreen(vehicleId: info.vehicle.id!),
                        ),
                      );
                    },
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
