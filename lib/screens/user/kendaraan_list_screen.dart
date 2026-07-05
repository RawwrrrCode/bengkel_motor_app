import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/vehicle_card.dart';
import 'tambah_kendaraan_screen.dart';
import 'vehicle_detail_screen.dart';

class KendaraanListScreen extends StatelessWidget {
  const KendaraanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = context.watch<AppProvider>().vehicles;

    return Scaffold(
      appBar: const TopBar(title: 'Kendaraan Saya', showLogo: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          ...vehicles.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VehicleCard(
                vehicle: v,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleDetailScreen(vehicleId: v.id),
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TambahKendaraanScreen(),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFC9D2E0),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(15),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 19, color: Color(0xFF667085)),
                    SizedBox(width: 8),
                    Text(
                      'Tambah Kendaraan',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
