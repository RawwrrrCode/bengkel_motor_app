import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/jasa.dart';
import '../../models/service_request.dart';
import '../../models/sparepart.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../widgets/top_bar.dart';

class _SelectedItem {
  final String nama;
  final int harga;
  final String? sparepartId;
  int qty;

  _SelectedItem({required this.nama, required this.harga, this.sparepartId}) : qty = 1;

  int get subtotal => harga * qty;

  ServiceItem toServiceItem() => ServiceItem(nama: nama, qty: qty, harga: harga);
}

class CompleteServiceScreen extends StatefulWidget {
  final String serviceId;

  const CompleteServiceScreen({super.key, required this.serviceId});

  @override
  State<CompleteServiceScreen> createState() => _CompleteServiceScreenState();
}

class _CompleteServiceScreenState extends State<CompleteServiceScreen> {
  final List<_SelectedItem> _selected = [];

  int get _total => _selected.fold(0, (a, i) => a + i.subtotal);

  int? _availableStok(String sparepartId) {
    final sparepart = context
        .read<AppProvider>()
        .spareparts
        .where((s) => s.id == sparepartId);
    return sparepart.isEmpty ? null : sparepart.first.stok;
  }

  void _addOrIncrement(String nama, int harga, String? sparepartId) {
    setState(() {
      final existing = _selected.where((i) => i.nama == nama && i.harga == harga);
      if (existing.isNotEmpty) {
        final item = existing.first;
        if (sparepartId != null) {
          final stok = _availableStok(sparepartId) ?? 0;
          if (item.qty >= stok) {
            showDemoSnackbar(context, 'Stok $nama tidak cukup');
            return;
          }
        }
        item.qty += 1;
      } else {
        _selected.add(_SelectedItem(nama: nama, harga: harga, sparepartId: sparepartId));
      }
    });
  }

  void _changeQty(int index, int delta) {
    final item = _selected[index];
    if (delta > 0 && item.sparepartId != null) {
      final stok = _availableStok(item.sparepartId!) ?? 0;
      if (item.qty >= stok) {
        showDemoSnackbar(context, 'Stok ${item.nama} tidak cukup');
        return;
      }
    }
    setState(() {
      final newQty = item.qty + delta;
      if (newQty <= 0) {
        _selected.removeAt(index);
      } else {
        item.qty = newQty;
      }
    });
  }

  void _removeItem(int index) => setState(() => _selected.removeAt(index));

  Future<void> _openPicker() async {
    final app = context.read<AppProvider>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ItemPickerSheet(
        spareparts: app.spareparts,
        jasaList: app.jasaList,
        onPick: _addOrIncrement,
      ),
    );
  }

  void _submit() {
    if (_selected.isEmpty) {
      showDemoSnackbar(context, 'Pilih minimal 1 sparepart/jasa');
      return;
    }
    final items = _selected.map((i) => i.toServiceItem()).toList();
    final stockDeductions = <String, int>{
      for (final i in _selected)
        if (i.sparepartId != null) i.sparepartId!: i.qty,
    };
    context
        .read<AppProvider>()
        .completeService(widget.serviceId, items, stockDeductions: stockDeductions);
    showDemoSnackbar(context, 'Servis ditandai selesai');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.read<AppProvider>().serviceById(widget.serviceId);

    return Scaffold(
      appBar: TopBar(title: 'Selesaikan Servis', subtitle: svc?.jenis, showBack: true),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                const Text('Rincian Biaya',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Pilih sparepart & jasa yang dikerjakan untuk servis ini.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                const SizedBox(height: 14),
                ...List.generate(_selected.length, (i) => _buildRow(i)),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    onTap: _openPicker,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFC9D2E0), width: 1.5, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18, color: Color(0xFF667085)),
                          SizedBox(width: 6),
                          Text('Pilih Sparepart / Jasa',
                              style: TextStyle(
                                  color: Color(0xFF667085), fontWeight: FontWeight.w700, fontSize: 13.5)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardBorderLight)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                    Text(AppFormatters.fmtRp(_total),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    child: const Text('Tandai Selesai',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int index) {
    final item = _selected[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('${AppFormatters.fmtRp(item.harga)} / item',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            _qtyStepper(index, item.qty),
            const SizedBox(width: 10),
            SizedBox(
              width: 84,
              child: Text(AppFormatters.fmtRp(item.subtotal),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
            ),
            IconButton(
              onPressed: () => _removeItem(index),
              icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyStepper(int index, int qty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperButton(Icons.remove, () => _changeQty(index, -1)),
        SizedBox(
          width: 26,
          child: Text('$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary)),
        ),
        _stepperButton(Icons.add, () => _changeQty(index, 1)),
      ],
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFF1F4F9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(width: 26, height: 26, child: Icon(icon, size: 15, color: AppColors.textPrimary)),
      ),
    );
  }
}

class _ItemPickerSheet extends StatefulWidget {
  final List<Sparepart> spareparts;
  final List<Jasa> jasaList;
  final void Function(String nama, int harga, String? sparepartId) onPick;

  const _ItemPickerSheet({required this.spareparts, required this.jasaList, required this.onPick});

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  String _tab = 'sparepart';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE1E6EF), borderRadius: BorderRadius.circular(999)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Expanded(child: _tabButton('sparepart', 'Sparepart')),
                    const SizedBox(width: 10),
                    Expanded(child: _tabButton('jasa', 'Jasa')),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: _tab == 'sparepart'
                      ? widget.spareparts
                          .map((p) => _tile(p.nama, p.harga, p.stok, p.id))
                          .toList()
                      : widget.jasaList.map((j) => _tile(j.nama, j.harga, null, null)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabButton(String tab, String label) {
    final on = _tab == tab;
    return Material(
      color: on ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => setState(() => _tab = tab),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: on ? Colors.transparent : const Color(0xFFE1E6EF)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : const Color(0xFF667085))),
        ),
      ),
    );
  }

  Widget _tile(String nama, int harga, int? stok, String? sparepartId) {
    final habis = stok != null && stok <= 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: habis
            ? null
            : () {
                widget.onPick(nama, harga, sparepartId);
                Navigator.of(context).pop();
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider))),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: habis ? AppColors.textMuted : AppColors.textPrimary)),
                    if (stok != null) ...[
                      const SizedBox(height: 2),
                      Text(habis ? 'Stok habis' : '$stok pcs tersedia',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: habis ? AppColors.batalFg : AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              Text(AppFormatters.fmtRp(harga),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Icon(Icons.add_circle,
                  size: 22, color: habis ? const Color(0xFFC9D2E0) : AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
