// lib/data/local/database/daos/staff_task_dao.dart

import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:hotel_management_app/data/models/staff_task_model.dart';

class StaffTaskDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get tasks by staff ID
  Future<List<StaffTask>> getTasksByStaff(int staffId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_tasks',
      where: 'staffId = ?',
      whereArgs: [staffId],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => StaffTask.fromMap(maps[i]));
  }

  // Get ALL tasks (for manager)
  Future<List<StaffTask>> getAllTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_tasks',
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => StaffTask.fromMap(maps[i]));
  }

  // Get tasks by status (for manager)
  Future<List<StaffTask>> getTasksByStatus(String status) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_tasks',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => StaffTask.fromMap(maps[i]));
  }

  // Get tasks by priority
  Future<List<StaffTask>> getTasksByPriority(String priority) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_tasks',
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => StaffTask.fromMap(maps[i]));
  }

  // Insert new task
  Future<int> insertTask(StaffTask task) async {
    final db = await _dbHelper.database;
    print('📝 Inserting new task: ${task.title}');
    try {
      final id = await db.insert('staff_tasks', task.toMap());
      print('✅ Task inserted with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error inserting task: $e');
      return 0;
    }
  }

  // Update task status
  Future<int> updateStatus(int taskId, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'staff_tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Update task (full update)
  Future<int> updateTask(StaffTask task) async {
    final db = await _dbHelper.database;
    return await db.update(
      'staff_tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete task
  Future<int> deleteTask(int taskId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'staff_tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Get task by ID
  Future<StaffTask?> getTaskById(int taskId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_tasks',
      where: 'id = ?',
      whereArgs: [taskId],
      limit: 1,
    );
    if (maps.isNotEmpty) return StaffTask.fromMap(maps.first);
    return null;
  }

  // Get tasks by date range
  Future<List<StaffTask>> getTasksByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_tasks',
      where: 'dueDate BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => StaffTask.fromMap(maps[i]));
  }
}