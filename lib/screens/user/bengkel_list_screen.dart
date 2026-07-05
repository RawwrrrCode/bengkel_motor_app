import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bengkel_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/top_bar.dart';
import 'bengkel_detail_screen.dart';

class BengkelListScreen extends StatefulWidget {
  final String? vehId;

  const BengkelListScreen({super.key, this.vehId});

  @override
  State<BengkelListScreen> createState() => _BengkelListScreenState();
}

class _BengkelListScreenState extends State<BengkelListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _sort = 'rating';
  bool _bukaOnly = false;

  static const _sorts = [
    ('rating', 'Rating tertinggi'),
    ('jarak', 'Jarak terdekat'),
    ('nama', 'Nama A-Z'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _jarakValue(String jarak) {
    final match = RegExp(r'[\d.,]+').firstMatch(jarak);
    if (match == null) return double.infinity;
    return double.tryParse(match.group(0)!.replaceAll(',', '.')) ??
        double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final bengkels = context.watch<AppProvider>().bengkels;
    final q = _query.trim().toLowerCase();

    final filtered = bengkels.where((b) {
      if (_bukaOnly && !b.buka) return false;
      if (q.isEmpty) return true;
      return b.nama.toLowerCase().contains(q) ||
          b.spesialis.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) {
        switch (_sort) {
          case 'jarak':
            return _jarakValue(a.jarak).compareTo(_jarakValue(b.jarak));
          case 'nama':
            return a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
          default:
            return b.rating.compareTo(a.rating);
        }
      });

    return Scaffold(
      appBar: const TopBar(title: 'Cari Bengkel', showLogo: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari nama bengkel atau spesialis...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              children: [
                ..._sorts.map((s) {
                  final on = _sort == s.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip(s.$2, on, () => setState(() => _sort = s.$1)),
                  );
                }),
                _chip(
                  'Buka saja',
                  _bukaOnly,
                  () => setState(() => _bukaOnly = !_bukaOnly),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    message: 'Tidak ada bengkel yang cocok dengan pencarianmu.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: filtered
                        .map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: BengkelCard(
                                bengkel: b,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BengkelDetailScreen(
                                      bengkelId: b.id,
                                      vehId: widget.vehId,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool on, VoidCallback onTap) {
    return Material(
      color: on ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: on ? Colors.transparent : const Color(0xFFE1E6EF),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: on ? Colors.white : const Color(0xFF667085),
            ),
          ),
        ),
      ),
    );
  }
}
