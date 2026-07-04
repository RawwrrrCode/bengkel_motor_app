import '../database/db_helper.dart';
import '../models/customer.dart';

class CustomerService {
  Future<List<Customer>> getAll() async {
    final db = await DbHelper.instance.database;
    final rows = await db.query('customers', orderBy: 'name ASC');
    return rows.map(Customer.fromMap).toList();
  }

  Future<int> insert(Customer customer) async {
    final db = await DbHelper.instance.database;
    return db.insert('customers', customer.toMap()..remove('id'));
  }

  Future<int> update(Customer customer) async {
    final db = await DbHelper.instance.database;
    return db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DbHelper.instance.database;
    return db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
