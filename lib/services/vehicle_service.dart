import '../database/db_helper.dart';
import '../models/vehicle.dart';

class VehicleService {
  Future<List<Vehicle>> getAll() async {
    final db = await DbHelper.instance.database;
    final rows = await db.query('vehicles', orderBy: 'plate_number ASC');
    return rows.map(Vehicle.fromMap).toList();
  }

  Future<List<Vehicle>> getByCustomer(int customerId) async {
    final db = await DbHelper.instance.database;
    final rows = await db.query(
      'vehicles',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'plate_number ASC',
    );
    return rows.map(Vehicle.fromMap).toList();
  }

  Future<int> insert(Vehicle vehicle) async {
    final db = await DbHelper.instance.database;
    return db.insert('vehicles', vehicle.toMap()..remove('id'));
  }

  Future<int> update(Vehicle vehicle) async {
    final db = await DbHelper.instance.database;
    return db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> updateOdometerIfHigher(int vehicleId, int odometer) async {
    final db = await DbHelper.instance.database;
    return db.rawUpdate(
      'UPDATE vehicles SET current_odometer = ? '
      'WHERE id = ? AND (current_odometer IS NULL OR current_odometer < ?)',
      [odometer, vehicleId, odometer],
    );
  }

  Future<int> delete(int id) async {
    final db = await DbHelper.instance.database;
    return db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }
}
