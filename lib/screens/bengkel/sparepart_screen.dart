import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/top_bar.dart';

class SparepartScreen extends StatefulWidget {
  const SparepartScreen({super.key});

  @override
  State<SparepartScreen> createState() => _SparepartScreenState();
}

class _SparepartScreenState extends State<SparepartScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showForm = false;
  String? _editingId;
  String _tab = 'sparepart';
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  void _openAddForm() {
    setState(() {
      _editingId = null;
      _namaController.clear();
      _hargaController.clear();
      _stokController.clear();
      _showForm = true;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingId = null;
      _namaController.clear();
      _hargaController.clear();
      _stokController.clear();
    });
  }

  void _toggleForm() {
    if (_showForm) {
      _closeForm();
    } else {
      _openAddForm();
    }
  }

  void _startEdit({
    required String id,
    required String nama,
    required int harga,
    int? stok,
  }) {
    setState(() {
      _editingId = id;
      _namaController.text = nama;
      _hargaController.text = harga.toString();
      _stokController.text = (stok ?? 0).toString();
      _showForm = true;
    });
  }

  void _selectTab(String tab) {
    if (_tab == tab) return;
    setState(() {
      _tab = tab;
      _showForm = false;
      _editingId = null;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final app = context.read<AppProvider>();
    final nama = _namaController.text.trim();
    final harga = int.parse(_hargaController.text.trim());
    final editingId = _editingId;
    if (_tab == 'sparepart') {
      final stok = int.parse(_stokController.text.trim());
      if (editingId != null) {
        app.updateSparepart(editingId, nama: nama, harga: harga, stok: stok);
        showDemoSnackbar(context, 'Sparepart diperbarui');
      } else {
        app.addSparepart(nama: nama, harga: harga, stok: stok);
        showDemoSnackbar(context, 'Sparepart ditambahkan');
      }
    } else {
      if (editingId != null) {
        app.updateJasa(editingId, nama: nama, harga: harga);
        showDemoSnackbar(context, 'Jasa diperbarui');
      } else {
        app.addJasa(nama: nama, harga: harga);
        showDemoSnackbar(context, 'Jasa ditambahkan');
      }
    }
    _closeForm();
  }

  Future<void> _confirmDelete({
    required String id,
    required String nama,
    required bool isSparepart,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${isSparepart ? 'Sparepart' : 'Jasa'}?'),
        content: Text(
          '"$nama" akan dihapus dari katalog dan tidak bisa dipilih lagi saat rincian biaya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.batalFg),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final app = context.read<AppProvider>();
      if (isSparepart) {
        app.deleteSparepart(id);
      } else {
        app.deleteJasa(id);
      }
      if (_editingId == id) _closeForm();
      showDemoSnackbar(
        context,
        '${isSparepart ? 'Sparepart' : 'Jasa'} dihapus',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final spareparts = app.spareparts;
    final jasaList = app.jasaList;
    final isSparepart = _tab == 'sparepart';
    final isEmpty = isSparepart ? spareparts.isEmpty : jasaList.isEmpty;

    return Scaffold(
      appBar: TopBar(
        title: 'Sparepart & Jasa',
        showLogo: true,
        onPlus: _toggleForm,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            children: [
              Expanded(child: _tabButton('sparepart', 'Sparepart')),
              const SizedBox(width: 10),
              Expanded(child: _tabButton('jasa', 'Jasa')),
            ],
          ),
          const SizedBox(height: 14),
          if (_showForm) _buildForm(),
          if (isEmpty)
            EmptyState(
              icon: isSparepart
                  ? Icons.inventory_2_outlined
                  : Icons.build_outlined,
              message: isSparepart
                  ? 'Belum ada sparepart di katalog.\nTap tombol + untuk menambahkan.'
                  : 'Belum ada jasa di katalog.\nTap tombol + untuk menambahkan.',
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: isSparepart
                    ? spareparts.map((p) {
                        final stokColor = p.stok > 5
                            ? AppColors.amanFg
                            : (p.stok > 0
                                  ? AppColors.segeraFg
                                  : AppColors.batalFg);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.divider),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          p.kategori,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '· ${p.stok > 0 ? '${p.stok} pcs' : 'Habis'}',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: stokColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                AppFormatters.fmtRp(p.harga),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              _rowActions(
                                onEdit: () => _startEdit(
                                  id: p.id,
                                  nama: p.nama,
                                  harga: p.harga,
                                  stok: p.stok,
                                ),
                                onDelete: () => _confirmDelete(
                                  id: p.id,
                                  nama: p.nama,
                                  isSparepart: true,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    : jasaList.map((j) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.divider),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  j.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                AppFormatters.fmtRp(j.harga),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              _rowActions(
                                onEdit: () => _startEdit(
                                  id: j.id,
                                  nama: j.nama,
                                  harga: j.harga,
                                ),
                                onDelete: () => _confirmDelete(
                                  id: j.id,
                                  nama: j.nama,
                                  isSparepart: false,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rowActions({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onEdit,
          icon: const Icon(
            Icons.edit_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline,
            size: 18,
            color: AppColors.batalFg,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _tabButton(String tab, String label) {
    final on = _tab == tab;
    return Material(
      color: on ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => _selectTab(tab),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: on ? Colors.transparent : const Color(0xFFE1E6EF),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: on ? Colors.white : const Color(0xFF667085),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final isSparepart = _tab == 'sparepart';
    final isEditing = _editingId != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing
                  ? 'Edit ${isSparepart ? 'Sparepart' : 'Jasa'}'
                  : (isSparepart ? 'Tambah Sparepart' : 'Tambah Jasa'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 11),
            _field(
              controller: _namaController,
              hint: isSparepart ? 'Nama sparepart' : 'Nama jasa',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    controller: _hargaController,
                    hint: 'Harga (Rp)',
                    numeric: true,
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null) return 'Harga wajib diisi';
                      if (n <= 0) return 'Harga harus > 0';
                      return null;
                    },
                  ),
                ),
                if (isSparepart) ...[
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: _field(
                      controller: _stokController,
                      hint: 'Stok',
                      numeric: true,
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        if (n == null) return 'Wajib diisi';
                        if (n < 0) return 'Tidak boleh negatif';
                        return null;
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: _closeForm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.chipBg,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Simpan Perubahan' : 'Simpan',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool numeric = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFE1E6EF), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFE1E6EF), width: 1.5),
        ),
      ),
    );
  }
}
