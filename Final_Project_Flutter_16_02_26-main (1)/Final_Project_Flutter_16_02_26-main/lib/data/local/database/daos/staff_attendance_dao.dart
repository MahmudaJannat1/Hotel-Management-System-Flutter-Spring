// lib/data/local/database/daos/staff/staff_attendance_dao.dart

import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/staff_attendance_model.dart';

class StaffAttendanceDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all attendance records for a staff member
  Future<List<StaffAttendance>> getAttendanceByStaff(int staffId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_attendance',
      where: 'staffId = ?',
      whereArgs: [staffId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => StaffAttendance.fromMap(maps[i]));
  }

  // Get today's attendance for a staff member
  Future<StaffAttendance?> getTodayAttendance(int staffId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_attendance',
      where: 'staffId = ? AND date = ?',
      whereArgs: [staffId, today],
      limit: 1,
    );
    if (maps.isNotEmpty) return StaffAttendance.fromMap(maps.first);
    return null;
  }

  // Mark attendance (check-in)
  Future<int> markAttendance(StaffAttendance attendance) async {
    final db = await _dbHelper.database;
    print('📝 Marking attendance for staff: ${attendance.staffId}');

    try {
      // Check if already checked in today
      final existing = await getTodayAttendance(attendance.staffId);
      if (existing != null) {
        print('⚠️ Already checked in today');
        return existing.id;
      }

      final id = await db.insert('staff_attendance', attendance.toMap());
      print('✅ Attendance marked with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error marking attendance: $e');
      return 0;
    }
  }

  // Update check-out time
  Future<int> updateCheckOut(int attendanceId, String checkOutTime) async {
    final db = await _dbHelper.database;
    print('📝 Updating check-out for attendance ID: $attendanceId');

    try {
      final count = await db.update(
        'staff_attendance',
        {'checkOutTime': checkOutTime},
        where: 'id = ?',
        whereArgs: [attendanceId],
      );
      print('✅ Check-out updated: $count');
      return count;
    } catch (e) {
      print('❌ Error updating check-out: $e');
      return 0;
    }
  }

  // Get attendance for a specific date range
  Future<List<StaffAttendance>> getAttendanceByDateRange(
      int staffId,
      DateTime startDate,
      DateTime endDate
      ) async {
    final db = await _dbHelper.database;
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'staff_attendance',
      where: 'staffId = ? AND date BETWEEN ? AND ?',
      whereArgs: [staffId, startStr, endStr],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => StaffAttendance.fromMap(maps[i]));
  }
}