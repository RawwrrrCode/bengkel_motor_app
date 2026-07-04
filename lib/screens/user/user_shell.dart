import 'package:flutter/material.dart';

import '../../widgets/tab_shell.dart';
import 'beranda_screen.dart';
import 'bengkel_list_screen.dart';
import 'histori_list_screen.dart';
import 'kendaraan_list_screen.dart';

class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
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
            icon: Icons.home_outlined,
            label: 'Beranda',
            rootBuilder: (_) => const BerandaScreen(),
          ),
          TabItemConfig(
            icon: Icons.two_wheeler_outlined,
            label: 'Kendaraan',
            rootBuilder: (_) => const KendaraanListScreen(),
          ),
          TabItemConfig(
            icon: Icons.store_outlined,
            label: 'Bengkel',
            rootBuilder: (_) => const BengkelListScreen(),
          ),
          TabItemConfig(
            icon: Icons.history,
            label: 'Histori',
            rootBuilder: (_) => const HistoriListScreen(),
          ),
        ],
      ),
    );
  }
}
