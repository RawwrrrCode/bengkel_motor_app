import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../utils/date_utils.dart';

class VehicleFormScreen extends StatefulWidget {
  final int customerId;
  final Vehicle? existing;

  const VehicleFormScreen({super.key, required this.customerId, this.existing});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _colorController;
  late final TextEditingController _odometerController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final v = widget.existing;
    _plateController = TextEditingController(text: v?.plateNumber);
    _brandController = TextEditingController(text: v?.brand);
    _modelController = TextEditingController(text: v?.model);
    _yearController = TextEditingController(text: v?.year?.toString());
    _colorController = TextEditingController(text: v?.color);
    _odometerController =
        TextEditingController(text: v?.currentOdometer?.toString());
    _notesController = TextEditingController(text: v?.notes);
  }

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VehicleProvider>();
    if (widget.existing == null) {
      await provider.add(Vehicle(
        customerId: widget.customerId,
        plateNumber: _plateController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.tryParse(_yearController.text.trim()),
        color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        currentOdometer: int.tryParse(_odometerController.text.trim()),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: AppDateUtils.nowIso(),
      ));
    } else {
      await provider.update(widget.existing!.copyWith(
        plateNumber: _plateController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.tryParse(_yearController.text.trim()),
        color: _colorController.text.trim(),
        currentOdometer: int.tryParse(_odometerController.text.trim()),
        notes: _notesController.text.trim(),
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Kendaraan' : 'Tambah Kendaraan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _plateController,
              decoration: const InputDecoration(labelText: 'Nomor Polisi *'),
              textCapitalization: TextCapitalization.characters,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Merk *'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Tipe/Model *'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Tahun'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(labelText: 'Warna'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(labelText: 'Odometer saat ini (km)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Catatan'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
