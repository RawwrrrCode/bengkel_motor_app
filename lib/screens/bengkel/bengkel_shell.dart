import 'package:flutter/material.dart';

import '../../widgets/tab_shell.dart';
import 'dashboard_screen.dart';
import 'pengajuan_list_screen.dart';
import 'profil_bengkel_screen.dart';
import 'sparepart_screen.dart';

class BengkelShell extends StatefulWidget {
  const BengkelShell({super.key});

  @override
  State<BengkelShell> createState() => _BengkelShellState();
}

class _BengkelShellState extends State<BengkelShell> {
  final controller = TabIndexController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabIndexScope(
      controller: controller,
      child: TabShell(
        controller: controller,
        tabs: [
          TabItemConfig(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            rootBuilder: (_) => const DashboardScreen(),
          ),
          TabItemConfig(
            icon: Icons.assignment_outlined,
            label: 'Pengajuan',
            rootBuilder: (_) => const PengajuanListScreen(),
          ),
          TabItemConfig(
            icon: Icons.inventory_2_outlined,
            label: 'Sparepart',
            rootBuilder: (_) => const SparepartScreen(),
          ),
          TabItemConfig(
            icon: Icons.person_outline,
            label: 'Profil',
            rootBuilder: (_) => const ProfilBengkelScreen(),
          ),
        ],
      ),
    );
  }
}
