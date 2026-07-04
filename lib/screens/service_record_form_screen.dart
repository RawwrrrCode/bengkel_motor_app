import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service_record.dart';
import '../providers/service_record_provider.dart';
import '../providers/vehicle_provider.dart';
import '../utils/date_utils.dart';

class ServiceRecordFormScreen extends StatefulWidget {
  final int vehicleId;
  final ServiceRecord? existing;

  const ServiceRecordFormScreen({super.key, required this.vehicleId, this.existing});

  @override
  State<ServiceRecordFormScreen> createState() => _ServiceRecordFormScreenState();
}

class _ServiceRecordFormScreenState extends State<ServiceRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _odometerController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costController;
  late final TextEditingController _mechanicNotesController;
  late final TextEditingController _intervalMonthsController;
  late final TextEditingController _intervalKmController;
  late DateTime _serviceDate;
  late ServiceStatus _status;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _serviceDate = r != null ? DateTime.parse(r.serviceDate) : DateTime.now();
    _status = r?.status ?? ServiceStatus.queued;
    _odometerController = TextEditingController(text: r?.odometer.toString());
    _descriptionController = TextEditingController(text: r?.description);
    _costController = TextEditingController(text: r?.cost?.toString());
    _mechanicNotesController = TextEditingController(text: r?.mechanicNotes);
    _intervalMonthsController =
        TextEditingController(text: r?.nextServiceIntervalMonths?.toString());
    _intervalKmController =
        TextEditingController(text: r?.nextServiceIntervalKm?.toString());
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _mechanicNotesController.dispose();
    _intervalMonthsController.dispose();
    _intervalKmController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _serviceDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final odometer = int.parse(_odometerController.text.trim());
    final recordProvider = context.read<ServiceRecordProvider>();
    final vehicleProvider = context.read<VehicleProvider>();

    if (widget.existing == null) {
      await recordProvider.add(ServiceRecord(
        vehicleId: widget.vehicleId,
        serviceDate: AppDateUtils.toIsoDate(_serviceDate),
        odometer: odometer,
        status: _status,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        cost: int.tryParse(_costController.text.trim()),
        mechanicNotes: _mechanicNotesController.text.trim().isEmpty
            ? null
            : _mechanicNotesController.text.trim(),
        nextServiceIntervalMonths: int.tryParse(_intervalMonthsController.text.trim()),
        nextServiceIntervalKm: int.tryParse(_intervalKmController.text.trim()),
        createdAt: AppDateUtils.nowIso(),
      ));
    } else {
      await recordProvider.update(widget.existing!.copyWith(
        serviceDate: AppDateUtils.toIsoDate(_serviceDate),
        odometer: odometer,
        status: _status,
        description: _descriptionController.text.trim(),
        cost: int.tryParse(_costController.text.trim()),
        mechanicNotes: _mechanicNotesController.text.trim(),
        nextServiceIntervalMonths: int.tryParse(_intervalMonthsController.text.trim()),
        nextServiceIntervalKm: int.tryParse(_intervalKmController.text.trim()),
      ));
    }

    await vehicleProvider.bumpOdometerIfHigher(widget.vehicleId, odometer);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Servis' : 'Tambah Servis')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal Servis'),
              subtitle: Text(AppDateUtils.formatDisplay(_serviceDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(labelText: 'Odometer (km) *'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Wajib diisi';
                if (int.tryParse(value.trim()) == null) return 'Harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ServiceStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ServiceStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi Pekerjaan'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(labelText: 'Biaya (Rp)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mechanicNotesController,
              decoration: const InputDecoration(labelText: 'Catatan Mekanik'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _intervalMonthsController,
                    decoration: const InputDecoration(
                      labelText: 'Interval bulan',
                      hintText: 'default 3',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _intervalKmController,
                    decoration: const InputDecoration(
                      labelText: 'Interval km',
                      hintText: 'default 2000',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
