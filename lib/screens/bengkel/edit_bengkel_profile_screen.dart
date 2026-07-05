import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/snackbar.dart';

/// Lets an existing bengkel owner edit the profile fields they filled in
/// during onboarding ([SetupBengkelScreen]) — nama, alamat, jam, spesialis.
class EditBengkelProfileScreen extends StatefulWidget {
  const EditBengkelProfileScreen({super.key});

  @override
  State<EditBengkelProfileScreen> createState() =>
      _EditBengkelProfileScreenState();
}

class _EditBengkelProfileScreenState extends State<EditBengkelProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _alamatController;
  late final TextEditingController _jamController;
  late final TextEditingController _spesialisController;
  late final TextEditingController _teleponController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final bengkel = context.read<AppProvider>().myBengkel;
    _namaController = TextEditingController(text: bengkel?.nama ?? '');
    _alamatController = TextEditingController(text: bengkel?.alamat ?? '');
    _jamController = TextEditingController(text: bengkel?.jam ?? '');
    _spesialisController = TextEditingController(
      text: bengkel?.spesialis ?? '',
    );
    _teleponController = TextEditingController(text: bengkel?.telepon ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _jamController.dispose();
    _spesialisController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    await context.read<AppProvider>().updateBengkelProfile(
      nama: _namaController.text.trim(),
      alamat: _alamatController.text.trim(),
      jam: _jamController.text.trim(),
      spesialis: _spesialisController.text.trim(),
      telepon: _teleponController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    showDemoSnackbar(context, 'Profil bengkel diperbarui');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBgBottom,
      appBar: AppBar(
        title: const Text('Edit Profil Bengkel'),
        backgroundColor: AppColors.pageBgBottom,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Bengkel',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama bengkel wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alamatController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Alamat wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jamController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Operasional',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Jam operasional wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _spesialisController,
                  decoration: const InputDecoration(
                    labelText: 'Spesialisasi',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Spesialisasi wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _teleponController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon / WhatsApp',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nomor telepon wajib diisi'
                      : null,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
