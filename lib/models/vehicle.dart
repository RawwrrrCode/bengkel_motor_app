class Vehicle {
  final int? id;
  final int customerId;
  final String plateNumber;
  final String brand;
  final String model;
  final int? year;
  final String? color;
  final int? currentOdometer;
  final String? notes;
  final String createdAt;

  Vehicle({
    this.id,
    required this.customerId,
    required this.plateNumber,
    required this.brand,
    required this.model,
    this.year,
    this.color,
    this.currentOdometer,
    this.notes,
    required this.createdAt,
  });

  Vehicle copyWith({
    int? id,
    int? customerId,
    String? plateNumber,
    String? brand,
    String? model,
    int? year,
    String? color,
    int? currentOdometer,
    String? notes,
    String? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      plateNumber: plateNumber ?? this.plateNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'plate_number': plateNumber,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'current_odometer': currentOdometer,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory Vehicle.fromMap(Map<String, Object?> map) {
    return Vehicle(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      plateNumber: map['plate_number'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int?,
      color: map['color'] as String?,
      currentOdometer: map['current_odometer'] as int?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
