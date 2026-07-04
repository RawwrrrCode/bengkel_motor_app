import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/service_record_provider.dart';
import '../providers/vehicle_provider.dart';
import '../services/reminder_service.dart';
import '../widgets/due_badge.dart';
import '../widgets/service_record_tile.dart';
import 'service_record_form_screen.dart';
import 'vehicle_form_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final int vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().load();
      context.read<ServiceRecordProvider>().loadForVehicle(widget.vehicleId);
    });
  }

  Future<void> _confirmDeleteVehicle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kendaraan'),
        content: const Text(
            'Menghapus kendaraan ini akan menghapus semua riwayat servisnya. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<VehicleProvider>().delete(widget.vehicleId);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _confirmDeleteRecord(int recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat Servis'),
        content: const Text('Yakin ingin menghapus catatan servis ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context
          .read<ServiceRecordProvider>()
          .delete(recordId, widget.vehicleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, _) {
        final vehicle = vehicleProvider.byId(widget.vehicleId);
        if (vehicle == null) {
          return const Scaffold(body: Center(child: Text('Kendaraan tidak ditemukan')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(vehicle.plateNumber),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VehicleFormScreen(
                        customerId: vehicle.customerId,
                        existing: vehicle,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _confirmDeleteVehicle,
              ),
            ],
          ),
          body: Consumer<ServiceRecordProvider>(
            builder: (context, recordProvider, _) {
              final records = recordProvider.forVehicle(widget.vehicleId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${vehicle.brand} ${vehicle.model} (${vehicle.year ?? '-'})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Warna: ${vehicle.color ?? '-'}'),
                        Text('Odometer saat ini: ${vehicle.currentOdometer ?? 0} km'),
                        if (records.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Builder(builder: (context) {
                            final evaluation = ReminderService.evaluate(
                              records.first,
                              vehicle.currentOdometer ?? records.first.odometer,
                            );
                            return Row(
                              children: [
                                const Text('Status servis: '),
                                DueBadge(status: evaluation.status),
                              ],
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Riwayat Servis', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: records.isEmpty
                        ? const Center(child: Text('Belum ada riwayat servis.'))
                        : ListView.builder(
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              return ServiceRecordTile(
                                record: record,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ServiceRecordFormScreen(
                                        vehicleId: widget.vehicleId,
                                        existing: record,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () => _confirmDeleteRecord(record.id!),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceRecordFormScreen(vehicleId: widget.vehicleId),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
