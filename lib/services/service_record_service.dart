import '../database/db_helper.dart';
import '../models/service_record.dart';

class ServiceRecordService {
  Future<List<ServiceRecord>> getByVehicle(int vehicleId) async {
    final db = await DbHelper.instance.database;
    final rows = await db.query(
      'service_records',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'service_date DESC, id DESC',
    );
    return rows.map(ServiceRecord.fromMap).toList();
  }

  Future<ServiceRecord?> getLatestForVehicle(int vehicleId) async {
    final db = await DbHelper.instance.database;
    final rows = await db.query(
      'service_records',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'service_date DESC, id DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ServiceRecord.fromMap(rows.first);
  }

  Future<Map<int, ServiceRecord>> getLatestPerVehicle() async {
    final db = await DbHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT sr.* FROM service_records sr
      INNER JOIN (
        SELECT vehicle_id, MAX(service_date) AS max_date
        FROM service_records
        GROUP BY vehicle_id
      ) latest
      ON sr.vehicle_id = latest.vehicle_id AND sr.service_date = latest.max_date
      GROUP BY sr.vehicle_id
    ''');
    final result = <int, ServiceRecord>{};
    for (final row in rows) {
      final record = ServiceRecord.fromMap(row);
      result[record.vehicleId] = record;
    }
    return result;
  }

  Future<int> insert(ServiceRecord record) async {
    final db = await DbHelper.instance.database;
    return db.insert('service_records', record.toMap()..remove('id'));
  }

  Future<int> update(ServiceRecord record) async {
    final db = await DbHelper.instance.database;
    return db.update(
      'service_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DbHelper.instance.database;
    return db.delete('service_records', where: 'id = ?', whereArgs: [id]);
  }
}
