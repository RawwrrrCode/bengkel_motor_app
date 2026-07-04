import '../database/db_helper.dart';
import '../models/service_record.dart';
import '../models/vehicle.dart';
import '../utils/constants.dart';

enum DueStatus { ok, dueSoon, overdue }

class VehicleDueInfo {
  final Vehicle vehicle;
  final String customerName;
  final ServiceRecord lastService;
  final DateTime dueDate;
  final int? dueOdometer;
  final DueStatus status;

  VehicleDueInfo({
    required this.vehicle,
    required this.customerName,
    required this.lastService,
    required this.dueDate,
    required this.dueOdometer,
    required this.status,
  });
}

class DueEvaluation {
  final DateTime dueDate;
  final int dueOdometer;
  final DueStatus status;

  DueEvaluation({
    required this.dueDate,
    required this.dueOdometer,
    required this.status,
  });
}

class ReminderService {
  /// Pure calculation shared by the dashboard's bulk query and any screen
  /// that needs a single vehicle's due status (e.g. VehicleDetailScreen).
  static DueEvaluation evaluate(ServiceRecord lastService, int currentOdometer) {
    final intervalMonths = lastService.nextServiceIntervalMonths ??
        AppConstants.defaultServiceIntervalMonths;
    final intervalKm = lastService.nextServiceIntervalKm ??
        AppConstants.defaultServiceIntervalKm;

    final lastServiceDate = DateTime.parse(lastService.serviceDate);
    final dueDate = DateTime(
      lastServiceDate.year,
      lastServiceDate.month + intervalMonths,
      lastServiceDate.day,
    );
    final dueOdometer = lastService.odometer + intervalKm;

    final now = DateTime.now();
    final isOverdueByDate = now.isAfter(dueDate);
    final isOverdueByKm = currentOdometer >= dueOdometer;

    final daysUntilDue = dueDate.difference(now).inDays;
    final kmUntilDue = dueOdometer - currentOdometer;

    final isDueSoonByDate =
        !isOverdueByDate && daysUntilDue <= AppConstants.dueSoonWarningDays;
    final isDueSoonByKm =
        !isOverdueByKm && kmUntilDue <= AppConstants.dueSoonWarningKm;

    DueStatus status;
    if (isOverdueByDate || isOverdueByKm) {
      status = DueStatus.overdue;
    } else if (isDueSoonByDate || isDueSoonByKm) {
      status = DueStatus.dueSoon;
    } else {
      status = DueStatus.ok;
    }

    return DueEvaluation(dueDate: dueDate, dueOdometer: dueOdometer, status: status);
  }

  /// Joins each vehicle with its most recent service record and evaluates
  /// whether the vehicle is due/overdue for its next service, using either
  /// the time-based interval or the km-based interval (whichever fires first).
  /// Vehicles with no service history are excluded — there is nothing to
  /// project a next-due date from yet.
  Future<List<VehicleDueInfo>> getVehiclesNeedingService() async {
    final db = await DbHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT
        v.*,
        c.name AS customer_name,
        sr.id AS sr_id,
        sr.service_date AS sr_service_date,
        sr.odometer AS sr_odometer,
        sr.status AS sr_status,
        sr.description AS sr_description,
        sr.cost AS sr_cost,
        sr.mechanic_notes AS sr_mechanic_notes,
        sr.next_service_interval_months AS sr_next_service_interval_months,
        sr.next_service_interval_km AS sr_next_service_interval_km,
        sr.created_at AS sr_created_at
      FROM vehicles v
      INNER JOIN customers c ON c.id = v.customer_id
      INNER JOIN (
        SELECT vehicle_id, MAX(service_date) AS max_date
        FROM service_records
        GROUP BY vehicle_id
      ) latest ON latest.vehicle_id = v.id
      INNER JOIN service_records sr
        ON sr.vehicle_id = latest.vehicle_id AND sr.service_date = latest.max_date
      GROUP BY v.id
    ''');

    final result = <VehicleDueInfo>[];

    for (final row in rows) {
      final vehicle = Vehicle.fromMap({
        'id': row['id'],
        'customer_id': row['customer_id'],
        'plate_number': row['plate_number'],
        'brand': row['brand'],
        'model': row['model'],
        'year': row['year'],
        'color': row['color'],
        'current_odometer': row['current_odometer'],
        'notes': row['notes'],
        'created_at': row['created_at'],
      });

      final lastService = ServiceRecord.fromMap({
        'id': row['sr_id'],
        'vehicle_id': row['id'],
        'service_date': row['sr_service_date'],
        'odometer': row['sr_odometer'],
        'status': row['sr_status'],
        'description': row['sr_description'],
        'cost': row['sr_cost'],
        'mechanic_notes': row['sr_mechanic_notes'],
        'next_service_interval_months': row['sr_next_service_interval_months'],
        'next_service_interval_km': row['sr_next_service_interval_km'],
        'created_at': row['sr_created_at'],
      });

      final currentOdometer = vehicle.currentOdometer ?? lastService.odometer;
      final evaluation = evaluate(lastService, currentOdometer);

      if (evaluation.status != DueStatus.ok) {
        result.add(VehicleDueInfo(
          vehicle: vehicle,
          customerName: row['customer_name'] as String,
          lastService: lastService,
          dueDate: evaluation.dueDate,
          dueOdometer: evaluation.dueOdometer,
          status: evaluation.status,
        ));
      }
    }

    result.sort((a, b) {
      if (a.status != b.status) {
        return a.status == DueStatus.overdue ? -1 : 1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return result;
  }
}
