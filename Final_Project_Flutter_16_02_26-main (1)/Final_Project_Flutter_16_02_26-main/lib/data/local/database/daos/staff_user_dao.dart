import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/staff_user_model.dart';

class StaffUserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(StaffUser user) async {
    final db = await _dbHelper.database;
    try {
      final existing = await db.query(
        'staff_users',
        where: 'email = ?',
        whereArgs: [user.email],
      );
      if (existing.isNotEmpty) {
        return existing.first['id'] as int;
      }
      final id = await db.insert('staff_users', user.toMap());
      return id;
    } catch (e) {
      print('StaffUser insert error: $e');
      return 0;
    }
  }

  Future<StaffUser?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isNotEmpty) return StaffUser.fromMap(maps.first);
    return null;
  }

  Future<StaffUser?> getLoggedInUser() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_users',
      where: 'isLoggedIn = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isNotEmpty) return StaffUser.fromMap(maps.first);
    return null;
  }

  Future<int> update(StaffUser user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'staff_users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> logoutAll() async {
    final db = await _dbHelper.database;
    await db.update('staff_users', {'isLoggedIn': 0}, where: '1 = 1');
  }
}