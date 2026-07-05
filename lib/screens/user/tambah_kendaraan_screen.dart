import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/snackbar.dart';
import '../../widgets/top_bar.dart';

class TambahKendaraanScreen extends StatefulWidget {
  const TambahKendaraanScreen({super.key});

  @override
  State<TambahKendaraanScreen> createState() => _TambahKendaraanScreenState();
}

class _TambahKendaraanScreenState extends State<TambahKendaraanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _merkController = TextEditingController();
  final _platController = TextEditingController();
  final _tahunController = TextEditingController();
  final _warnaController = TextEditingController();
  final _ccController = TextEditingController();
  final _kmController = TextEditingController();
  String _tipe = 'Matic';

  static const _tipeOptions = ['Matic', 'Bebek', 'Sport'];

  @override
  void dispose() {
    _namaController.dispose();
    _merkController.dispose();
    _platController.dispose();
    _tahunController.dispose();
    _warnaController.dispose();
    _ccController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AppProvider>().addVehicle(
      nama: _namaController.text.trim(),
      merk: _merkController.text.trim(),
      plat: _platController.text.trim(),
      tahun: int.parse(_tahunController.text.trim()),
      warna: _warnaController.text.trim(),
      tipe: _tipe,
      cc: int.parse(_ccController.text.trim()),
      km: int.parse(_kmController.text.trim()),
    );
    showDemoSnackbar(context, 'Kendaraan ditambahkan');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Tambah Kendaraan', showBack: true),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _field(
              controller: _namaController,
              hint: 'Nama kendaraan (mis. Honda Vario 160)',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            _field(
              controller: _merkController,
              hint: 'Merk (mis. Honda)',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            _field(
              controller: _platController,
              hint: 'Plat nomor (mis. B 1234 XYZ)',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    controller: _tahunController,
                    hint: 'Tahun',
                    numeric: true,
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null) return 'Wajib diisi';
                      if (n < 1990 || n > 2100) return 'Tahun tidak valid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    controller: _warnaController,
                    hint: 'Warna',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _dropdownShell(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _tipe,
                  items: _tipeOptions
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _tipe = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    controller: _ccController,
                    hint: 'CC mesin',
                    numeric: true,
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null) return 'Wajib diisi';
                      if (n <= 0) return 'Harus > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    controller: _kmController,
                    hint: 'KM saat ini',
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
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'Simpan Kendaraan',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E6EF), width: 1.5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: child,
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
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE1E6EF), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE1E6EF), width: 1.5),
        ),
      ),
    );
  }
}
