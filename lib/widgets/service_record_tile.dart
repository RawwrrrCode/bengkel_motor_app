import 'package:flutter/material.dart';

import '../models/service_record.dart';
import '../utils/date_utils.dart';

class ServiceRecordTile extends StatelessWidget {
  final ServiceRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ServiceRecordTile({
    super.key,
    required this.record,
    this.onTap,
    this.onDelete,
  });

  Color _statusColor() {
    switch (record.status) {
      case ServiceStatus.queued:
        return Colors.grey;
      case ServiceStatus.inProgress:
        return Colors.blue;
      case ServiceStatus.done:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final costText =
        record.cost != null ? 'Rp ${record.cost}' : 'Belum ada biaya';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _statusColor().withValues(alpha: 0.2),
        child: Icon(Icons.build, color: _statusColor()),
      ),
      title: Text(record.description?.isNotEmpty == true
          ? record.description!
          : 'Servis'),
      subtitle: Text(
        '${AppDateUtils.formatDisplayFromIso(record.serviceDate)} • '
        '${record.odometer} km • ${record.status.label} • $costText',
      ),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            )
          : null,
    );
  }
}
