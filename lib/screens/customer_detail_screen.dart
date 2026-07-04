import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customer_provider.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/vehicle_card.dart';
import 'customer_form_screen.dart';
import 'vehicle_detail_screen.dart';
import 'vehicle_form_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().load();
      context.read<VehicleProvider>().load();
    });
  }

  Future<void> _confirmDeleteCustomer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: const Text(
            'Menghapus pelanggan ini akan menghapus semua kendaraan dan riwayat servisnya. Lanjutkan?'),
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

    if (confirmed != true || !mounted) return;
    final customerProvider = context.read<CustomerProvider>();
    final vehicleProvider = context.read<VehicleProvider>();

    await customerProvider.delete(widget.customerId);
    if (!mounted) return;
    await vehicleProvider.load();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, _) {
        final customer = customerProvider.byId(widget.customerId);
        if (customer == null) {
          return const Scaffold(body: Center(child: Text('Pelanggan tidak ditemukan')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerFormScreen(existing: customer),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _confirmDeleteCustomer,
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No. HP: ${customer.phone ?? '-'}'),
                    Text('Alamat: ${customer.address ?? '-'}'),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Kendaraan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Consumer<VehicleProvider>(
                  builder: (context, vehicleProvider, _) {
                    final vehicles = vehicleProvider.byCustomer(widget.customerId);
                    if (vehicles.isEmpty) {
                      return const Center(
                        child: Text('Belum ada kendaraan untuk pelanggan ini.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return VehicleCard(
                          vehicle: vehicle,
                          subtitle:
                              '${vehicle.year ?? '-'} • ${vehicle.currentOdometer ?? 0} km',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VehicleDetailScreen(vehicleId: vehicle.id!),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleFormScreen(customerId: widget.customerId),
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
