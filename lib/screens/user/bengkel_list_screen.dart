import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/bengkel_card.dart';
import '../../widgets/top_bar.dart';
import 'bengkel_detail_screen.dart';

class BengkelListScreen extends StatelessWidget {
  final String? vehId;

  const BengkelListScreen({super.key, this.vehId});

  @override
  Widget build(BuildContext context) {
    final bengkels = context.watch<AppProvider>().bengkels;

    return Scaffold(
      appBar: const TopBar(title: 'Cari Bengkel', showLogo: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: bengkels
            .map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BengkelCard(
                    bengkel: b,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => BengkelDetailScreen(bengkelId: b.id, vehId: vehId))),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
