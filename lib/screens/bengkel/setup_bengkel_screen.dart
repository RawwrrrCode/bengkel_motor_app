import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';

/// One-time onboarding shown right after an account picks the "Pemilik
/// Bengkel" role but hasn't created their bengkel profile yet ([AuthGate]
/// routes here whenever `activeRole == bengkel && myBengkelId == null`).
class SetupBengkelScreen extends StatefulWidget {
  const SetupBengkelScreen({super.key});

  @override
  State<SetupBengkelScreen> createState() => _SetupBengkelScreenState();
}

class _SetupBengkelScreenState extends State<SetupBengkelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _jamController = TextEditingController(text: '08.00 – 17.00');
  final _spesialisController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _jamController.dispose();
    _spesialisController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    await context.read<AppProvider>().completeBengkelSetup(
          nama: _namaController.text.trim(),
          alamat: _alamatController.text.trim(),
          jam: _jamController.text.trim(),
          spesialis: _spesialisController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBgBottom,
      appBar: AppBar(
        title: const Text('Lengkapi Profil Bengkel'),
        backgroundColor: AppColors.pageBgBottom,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ceritakan tentang bengkelmu supaya pelanggan bisa menemukan dan booking servis.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
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
                    labelText: 'Spesialisasi (mis. Spesialis Motor Matic)',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Spesialisasi wajib diisi'
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
                          'Selesai',
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
