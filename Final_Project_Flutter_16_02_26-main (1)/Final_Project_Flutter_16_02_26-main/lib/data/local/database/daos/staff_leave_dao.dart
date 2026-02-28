// lib/data/local/database/daos/staff/staff_leave_dao.dart

import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/staff_leave_balance.dart';
import '../../../models/staff_leave_model.dart';

class StaffLeaveDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Create leave_balances table
  Future<void> createLeaveBalancesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS staff_leave_balances (
        staffId INTEGER PRIMARY KEY,
        staffName TEXT,
        sickLeaveTotal INTEGER DEFAULT 10,
        sickLeaveUsed INTEGER DEFAULT 0,
        casualLeaveTotal INTEGER DEFAULT 12,
        casualLeaveUsed INTEGER DEFAULT 0,
        annualLeaveTotal INTEGER DEFAULT 20,
        annualLeaveUsed INTEGER DEFAULT 0,
        emergencyLeaveTotal INTEGER DEFAULT 5,
        emergencyLeaveUsed INTEGER DEFAULT 0
      )
    ''');
  }

  // Create leave_applications table
  Future<void> createLeaveApplicationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS staff_leave_applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staffId INTEGER,
        staffName TEXT,
        leaveType TEXT,
        startDate TEXT,
        endDate TEXT,
        totalDays INTEGER,
        reason TEXT,
        status TEXT DEFAULT 'Pending',
        appliedOn TEXT,
        approvedBy TEXT,
        approvedDate TEXT,
        rejectionReason TEXT,
        documents TEXT
      )
    ''');
  }

  // Initialize leave balance for new staff
  Future<void> initializeLeaveBalance(StaffLeaveBalance balance) async {
    final db = await _dbHelper.database;
    await db.insert(
      'staff_leave_balances',
      balance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  // Update leave status (for manager)
  Future<int> updateLeaveStatus(int leaveId, String status, {String? approvedBy, String? rejectionReason}) async {
    final db = await _dbHelper.database;

    final Map<String, dynamic> updateData = {
      'status': status,
    };

    if (status == 'Approved') {
      updateData['approvedBy'] = approvedBy;
      updateData['approvedDate'] = DateTime.now().toIso8601String();
    } else if (status == 'Rejected') {
      updateData['rejectionReason'] = rejectionReason;
    }

    return await db.update(
      'staff_leave_applications',
      updateData,
      where: 'id = ?',
      whereArgs: [leaveId],
    );
  }

  // Update leave balance after approval
  Future<void> updateLeaveBalance(int staffId, String leaveType, int days) async {
    final db = await _dbHelper.database;
    final balance = await getLeaveBalance(staffId);

    if (balance != null) {
      Map<String, dynamic> updateMap = {};

      switch (leaveType) {
        case 'Sick':
          updateMap['sickLeaveUsed'] = balance.sickLeaveUsed + days;
          break;
        case 'Casual':
          updateMap['casualLeaveUsed'] = balance.casualLeaveUsed + days;
          break;
        case 'Annual':
          updateMap['annualLeaveUsed'] = balance.annualLeaveUsed + days;
          break;
        case 'Emergency':
          updateMap['emergencyLeaveUsed'] = balance.emergencyLeaveUsed + days;
          break;
      }

      await db.update(
        'staff_leave_balances',
        updateMap,
        where: 'staffId = ?',
        whereArgs: [staffId],
      );
    }
  }


  Future<List<StaffLeave>> getStaffLeaves(int staffId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_leave_applications',
      where: 'staffId = ?',
      whereArgs: [staffId],
      orderBy: 'appliedOn DESC',
    );
    return List.generate(maps.length, (i) => StaffLeave.fromMap(maps[i]));
  }

  Future<StaffLeaveBalance?> getLeaveBalance(int staffId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_leave_balances',
      where: 'staffId = ?',
      whereArgs: [staffId],
    );
    if (maps.isNotEmpty) {
      return StaffLeaveBalance.fromMap(maps.first);
    }
    return null;
  }

  Future<int> applyLeave(StaffLeave leave) async {
    final db = await _dbHelper.database;
    print('📝 Applying for leave: ${leave.leaveType}');

    try {
      final id = await db.insert('staff_leave_applications', leave.toMap());
      print('✅ Leave application submitted with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error applying leave: $e');
      return 0;
    }
  }

  // Add these to StaffLeaveDao

// Get all leave applications (for manager)
  Future<List<StaffLeave>> getAllLeaveApplications() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff_leave_applications',
      orderBy: 'appliedOn DESC',
    );
    return List.generate(maps.length, (i) => StaffLeave.fromMap(maps[i]));
  }

// Approve leave
  Future<bool> approveLeave(int leaveId, String approvedBy) async {
    final db = await _dbHelper.database;

    try {
      // Get leave details first
      final leaveData = await db.query(
        'staff_leave_applications',
        where: 'id = ?',
        whereArgs: [leaveId],
      );

      if (leaveData.isEmpty) return false;

      final leave = StaffLeave.fromMap(leaveData.first);

      // Update leave status
      await db.update(
        'staff_leave_applications',
        {
          'status': 'Approved',
          'approvedBy': approvedBy,
          'approvedDate': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [leaveId],
      );

      // Update leave balance
      await _updateLeaveBalanceAfterApproval(leave.staffId, leave.leaveType, leave.totalDays);

      return true;
    } catch (e) {
      print('❌ Approve leave error: $e');
      return false;
    }
  }

// Reject leave
  Future<bool> rejectLeave(int leaveId, String reason, String rejectedBy) async {
    final db = await _dbHelper.database;

    try {
      await db.update(
        'staff_leave_applications',
        {
          'status': 'Rejected',
          'rejectionReason': reason,
          'approvedBy': rejectedBy,
          'approvedDate': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [leaveId],
      );
      return true;
    } catch (e) {
      print('❌ Reject leave error: $e');
      return false;
    }
  }

// Cancel leave (by staff)
  Future<bool> cancelLeave(int leaveId) async {
    final db = await _dbHelper.database;

    try {
      await db.update(
        'staff_leave_applications',
        {'status': 'Cancelled'},
        where: 'id = ?',
        whereArgs: [leaveId],
      );
      return true;
    } catch (e) {
      print('❌ Cancel leave error: $e');
      return false;
    }
  }

// Update leave balance after approval
  Future<void> _updateLeaveBalanceAfterApproval(int staffId, String leaveType, int days) async {
    final db = await _dbHelper.database;

    final balance = await getLeaveBalance(staffId);
    if (balance == null) return;

    Map<String, dynamic> updateMap = {};

    switch (leaveType) {
      case 'Sick':
        updateMap['sickLeaveUsed'] = balance.sickLeaveUsed + days;
        break;
      case 'Casual':
        updateMap['casualLeaveUsed'] = balance.casualLeaveUsed + days;
        break;
      case 'Annual':
        updateMap['annualLeaveUsed'] = balance.annualLeaveUsed + days;
        break;
      case 'Emergency':
        updateMap['emergencyLeaveUsed'] = balance.emergencyLeaveUsed + days;
        break;
    }

    await db.update(
      'staff_leave_balances',
      updateMap,
      where: 'staffId = ?',
      whereArgs: [staffId],
    );
  }

}