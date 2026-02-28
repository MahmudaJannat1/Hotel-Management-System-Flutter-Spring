// lib/data/local/database/daos/guest_user_dao.dart

import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:hotel_management_app/data/models/guest_user_model.dart';
import 'package:sqflite/sqflite.dart';

class GuestUserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ========== INSERT ==========

  Future<int> insert(GuestUser user) async {
    final db = await _dbHelper.database;
    print('📝 Inserting guest user: ${user.email}');

    try {
      // Check if user already exists
      final existing = await db.query(
        'guest_users',
        where: 'email = ?',
        whereArgs: [user.email],
      );

      if (existing.isNotEmpty) {
        print('⚠️ User already exists: ${user.email}');
        return existing.first['id'] as int;
      }

      final id = await db.insert(
        'guest_users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      print('✅ Guest user inserted with ID: $id');
      return id;
    } catch (e) {
      print('❌ Guest user insert error: $e');
      return 0;
    }
  }

  // ========== UPDATE ==========

  Future<int> update(GuestUser user) async {
    final db = await _dbHelper.database;
    print('========== GUEST USER DAO UPDATE ==========');
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
        print('❌ ERROR: No guest user found with id: ${user.id}');

        // সব users দেখান
        final allUsers = await db.query('guest_users');
        print('📋 All guest users in database:');
        for (var u in allUsers) {
          print('   ID: ${u['id']}, Email: ${u['email']}');
        }
        print('==========================================');
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

      print('✅ Guest user update count: $count');

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

      print('==========================================');
      return count;
    } catch (e) {
      print('❌ Guest user database error: $e');
      print('==========================================');
      return 0;
    }
  }

  // ========== SELECT ==========

  Future<GuestUser?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'guest_users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        print('✅ Found guest user: ${maps.first['email']}');
        return GuestUser.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting guest user by email: $e');
      return null;
    }
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
        print('✅ Found logged in guest user: ${maps.first['email']}');
        return GuestUser.fromMap(maps.first);
      }

      print('⚠️ No guest user logged in');
      return null;
    } catch (e) {
      print('❌ Error getting logged in guest user: $e');
      return null;
    }
  }

  // ========== LOGOUT ALL ==========

  Future<void> logoutAll() async {
    final db = await _dbHelper.database;

    try {
      await db.update(
        'guest_users',
        {'isLoggedIn': 0},
        where: '1 = 1', // Update all rows
      );
      print('✅ All guest users logged out');
    } catch (e) {
      print('❌ Error logging out guest users: $e');
    }
  }

  // ========== DELETE ==========

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;

    try {
      final count = await db.delete(
        'guest_users',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('✅ Deleted guest user count: $count');
      return count;
    } catch (e) {
      print('❌ Error deleting guest user: $e');
      return 0;
    }
  }
}