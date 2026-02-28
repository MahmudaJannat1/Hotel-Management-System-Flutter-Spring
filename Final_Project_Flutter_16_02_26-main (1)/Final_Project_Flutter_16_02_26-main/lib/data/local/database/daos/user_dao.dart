import 'package:sqflite/sqflite.dart';
import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:hotel_management_app/data/models/user_model.dart';

import '../../../models/guest_user_model.dart';

class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(GuestUser user) async {
    final db = await _dbHelper.database;
    print('📝 Inserting user: ${user.email}');

    try {
      final id = await db.insert(
        'guest_users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      print('✅ User inserted with ID: $id');
      return id;
    } catch (e) {
      print('❌ User insert error: $e');
      return 0;
    }
  }

  Future<void> insertAll(List<User> users) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var user in users) {
      batch.insert(
        'users',
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User.fromJson(maps[i]);
    });
  }

  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }



  Future<int> update(GuestUser user) async {
    final db = await _dbHelper.database;
    print('========== USER DAO UPDATE ==========');
    print('📝 Updating guest user in DB: ${user.id}');
    print('📦 Update data: ${user.toMap()}');

    try {
      // প্রথমে check করুন user টি আছে কিনা
      final existing = await db.query(
        'guest_users',
        where: 'id = ?',
        whereArgs: [user.id],
      );

      print('🔍 Existing user count: ${existing.length}');

      if (existing.isEmpty) {
        print('❌ ERROR: No user found with id: ${user.id}');

        // সব users দেখান
        final allUsers = await db.query('guest_users');
        print('📋 All users in database:');
        for (var u in allUsers) {
          print('   ID: ${u['id']}, Email: ${u['email']}');
        }
        print('=====================================');
        return 0;
      }

      print('📋 Current data in DB: ${existing.first}');

      // UPDATE চেষ্টা করুন
      final count = await db.update(
        'guest_users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );

      print('✅ Update count: $count');

      // আবার read করে দেখুন
      if (count > 0) {
        final updated = await db.query(
          'guest_users',
          where: 'id = ?',
          whereArgs: [user.id],
        );
        print('📋 After update: ${updated.first}');
      } else {
        print('⚠️ No rows affected. Check if data is same as before?');
      }

      print('=====================================');
      return count;
    } catch (e) {
      print('❌ Database error: $e');
      print('=====================================');
      return 0;
    }
  }


  Future<int> delete(int id) async {
    final db = await _dbHelper.database;

    try {
      final count = await db.delete(
        'guest_users',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('✅ Deleted user count: $count');
      return count;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return 0;
    }
  }


  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('users');
  }

  Future<List<User>> getUsersByRole(String role) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
    );

    return List.generate(maps.length, (i) {
      return User.fromJson(maps[i]);
    });
  }

  Future<List<User>> getActiveUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'isActive = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return User.fromJson(maps[i]);
    });
  }

  Future<GuestUser?> getLoggedInUser() async {
    final db = await _dbHelper.database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'guest_users',
        where: 'isLoggedIn = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        print('✅ Found logged in user: ${maps.first['email']}');
        return GuestUser.fromMap(maps.first);
      }

      print('⚠️ No user logged in');
      return null;
    } catch (e) {
      print('❌ Error getting logged in user: $e');
      return null;
    }
  }

  Future<void> logoutAll() async {
    final db = await _dbHelper.database;

    try {
      await db.update(
        'guest_users',
        {'isLoggedIn': 0},
        where: '1 = 1', // Update all rows
      );
      print('✅ All users logged out');
    } catch (e) {
      print('❌ Error logging out users: $e');
    }
  }

}