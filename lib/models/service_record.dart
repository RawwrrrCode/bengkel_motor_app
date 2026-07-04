enum ServiceStatus { queued, inProgress, done }

extension ServiceStatusX on ServiceStatus {
  String get dbValue {
    switch (this) {
      case ServiceStatus.queued:
        return 'queued';
      case ServiceStatus.inProgress:
        return 'in_progress';
      case ServiceStatus.done:
        return 'done';
    }
  }

  String get label {
    switch (this) {
      case ServiceStatus.queued:
        return 'Antri';
      case ServiceStatus.inProgress:
        return 'Dikerjakan';
      case ServiceStatus.done:
        return 'Selesai';
    }
  }

  static ServiceStatus fromDbValue(String value) {
    switch (value) {
      case 'in_progress':
        return ServiceStatus.inProgress;
      case 'done':
        return ServiceStatus.done;
      case 'queued':
      default:
        return ServiceStatus.queued;
    }
  }
}

class ServiceRecord {
  final int? id;
  final int vehicleId;
  final String serviceDate;
  final int odometer;
  final ServiceStatus status;
  final String? description;
  final int? cost;
  final String? mechanicNotes;
  final int? nextServiceIntervalMonths;
  final int? nextServiceIntervalKm;
  final String createdAt;

  ServiceRecord({
    this.id,
    required this.vehicleId,
    required this.serviceDate,
    required this.odometer,
    required this.status,
    this.description,
    this.cost,
    this.mechanicNotes,
    this.nextServiceIntervalMonths,
    this.nextServiceIntervalKm,
    required this.createdAt,
  });

  ServiceRecord copyWith({
    int? id,
    int? vehicleId,
    String? serviceDate,
    int? odometer,
    ServiceStatus? status,
    String? description,
    int? cost,
    String? mechanicNotes,
    int? nextServiceIntervalMonths,
    int? nextServiceIntervalKm,
    String? createdAt,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceDate: serviceDate ?? this.serviceDate,
      odometer: odometer ?? this.odometer,
      status: status ?? this.status,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      mechanicNotes: mechanicNotes ?? this.mechanicNotes,
      nextServiceIntervalMonths:
          nextServiceIntervalMonths ?? this.nextServiceIntervalMonths,
      nextServiceIntervalKm: nextServiceIntervalKm ?? this.nextServiceIntervalKm,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'service_date': serviceDate,
      'odometer': odometer,
      'status': status.dbValue,
      'description': description,
      'cost': cost,
      'mechanic_notes': mechanicNotes,
      'next_service_interval_months': nextServiceIntervalMonths,
      'next_service_interval_km': nextServiceIntervalKm,
      'created_at': createdAt,
    };
  }

  factory ServiceRecord.fromMap(Map<String, Object?> map) {
    return ServiceRecord(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      serviceDate: map['service_date'] as String,
      odometer: map['odometer'] as int,
      status: ServiceStatusX.fromDbValue(map['status'] as String),
      description: map['description'] as String?,
      cost: map['cost'] as int?,
      mechanicNotes: map['mechanic_notes'] as String?,
      nextServiceIntervalMonths: map['next_service_interval_months'] as int?,
      nextServiceIntervalKm: map['next_service_interval_km'] as int?,
      createdAt: map['created_at'] as String,
    );
  }
}
