import 'package:hotel_management_app/data/local/database/database_helper.dart';

import '../../../models/staff_schedule_model.dart';


class StaffScheduleDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<StaffSchedule>> getSchedulesByStaff(int staffId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_schedules',
      where: 'staffId = ?',
      whereArgs: [staffId],
      orderBy: 'workDate DESC',
    );
    return List.generate(maps.length, (i) => StaffSchedule.fromMap(maps[i]));
  }

  Future<List<StaffSchedule>> getTodaysSchedules() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_schedules',
      where: 'workDate = ?',
      whereArgs: [today],
    );
    return List.generate(maps.length, (i) => StaffSchedule.fromMap(maps[i]));
  }
}