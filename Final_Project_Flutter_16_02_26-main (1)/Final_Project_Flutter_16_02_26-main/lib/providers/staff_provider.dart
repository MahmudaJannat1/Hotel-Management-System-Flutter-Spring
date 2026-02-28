import 'package:flutter/material.dart';

import 'package:hotel_management_app/data/repositories/staff_repository.dart';

import '../data/local/database/database_helper.dart';
import '../data/models/staff_attendance_model.dart';
import '../data/models/staff_leave_balance.dart';
import '../data/models/staff_leave_model.dart';
import '../data/models/staff_schedule_model.dart';
import '../data/models/staff_task_model.dart';
import '../data/models/staff_user_model.dart';
import '../data/repositories/staff_repository.dart';

class StaffProvider extends ChangeNotifier {
  final StaffRepository _repository = StaffRepository();

  StaffUser? _currentUser;
  List<StaffTask> _tasks = [];
  List<StaffSchedule> _schedules = [];
  List<StaffAttendance> _attendances = [];
  bool _isLoading = false;
  String? _error;

  StaffUser? get currentUser => _currentUser;
  List<StaffTask> get tasks => _tasks;
  List<StaffSchedule> get schedules => _schedules;
  List<StaffAttendance> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

// In staff_provider.dart - update login method
// Add this method to StaffProvider class

  Future<void> insertStaffDemoData() async {
    print('📝 Inserting staff demo data...');

    try {
      final db = await DatabaseHelper.instance.database;

      // First, check if users already exist
      final existing = await db.query('staff_users');
      if (existing.isNotEmpty) {
        print('✅ Staff users already exist: ${existing.length}');
        // Print existing users for debugging
        for (var user in existing) {
          print('   - ${user['email']} (${user['name']})');
        }
        return;
      }

      // Insert staff users
      List<Map<String, dynamic>> staffUsers = [
        {
          'name': 'Ama',
          'email': 'man@g.com',
          'password': '123456',
          'role': 'Manager',
          'phone': '+8801711111111',
          'address': 'Dhaka',
          'isLoggedIn': 0,
        },
        {
          'name': 'Sima',
          'email': 'recep@g.com',
          'password': '123456',
          'role': 'Receptionist',
          'phone': '+8801722222222',
          'address': 'Dhaka',
          'isLoggedIn': 0,
        },
        {
          'name': 'Karim',
          'email': 'house@g.com',
          'password': '123456',
          'role': 'Housekeeping',
          'phone': '+8801733333333',
          'address': 'Dhaka',
          'isLoggedIn': 0,
        },
      ];

      for (var user in staffUsers) {
        try {
          final id = await db.insert('staff_users', user);
          print('✅ Inserted: ${user['email']} with ID: $id');
        } catch (e) {
          print('❌ Failed to insert ${user['email']}: $e');
        }
      }

      // Verify insertion
      final verify = await db.query('staff_users');
      print('✅ Total staff users after insertion: ${verify.length}');

    } catch (e) {
      print('❌ Error inserting staff demo data: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Attempting login for: $email');

      // Check if user exists
      final user = await _repository.getUserByEmail(email);

      if (user == null) {
        print('❌ No user found with email: $email');

        // DEBUG: Check all users in database
        // You need to add this method temporarily
        await _debugPrintAllUsers();

        throw Exception('User not found');
      }

      print('✅ User found: ${user.name}');
      print('🔑 Password check: provided="$password", stored="${user.password}"');

      if (user.password == password) {
        await _repository.logoutAll();
        final updatedUser = StaffUser(
          id: user.id,
          name: user.name,
          email: user.email,
          password: user.password,
          role: user.role,
          phone: user.phone,
          address: user.address,
          isLoggedIn: true,
        );
        await _repository.updateUser(updatedUser);
        _currentUser = updatedUser;
        await loadStaffData(user.id);
        _isLoading = false;
        notifyListeners();
        print('✅ Login successful!');
        return true;
      } else {
        print('❌ Password mismatch');
        throw Exception('Invalid password');
      }
    } catch (e) {
      print('❌ Login error: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

// Add this temporary debug method
  Future<void> _debugPrintAllUsers() async {
    try {
      // You need to add this method to your DAO temporarily
      // This is just for debugging
      print('📋 Checking all staff users in database...');
    } catch (e) {
      print('Debug error: $e');
    }
  }



  Future<void> logout() async {
    await _repository.logoutAll();
    _currentUser = null;
    _tasks = [];
    _schedules = [];
    _attendances = [];
    notifyListeners();
  }

  Future<void> loadStaffData(int staffId) async {
    _tasks = await _repository.getTasksByStaff(staffId);
    _schedules = await _repository.getSchedulesByStaff(staffId);
    _attendances = await _repository.getAttendanceByStaff(staffId);
    notifyListeners();
  }

  Future<void> checkLoggedInUser() async {
    _currentUser = await _repository.getLoggedInUser();
    if (_currentUser != null) {
      await loadStaffData(_currentUser!.id);
    }
    notifyListeners();
  }



  Future<bool> updateTaskStatus(int taskId, String newStatus) async {
    // Don't set isLoading to true to avoid UI flicker
    // _isLoading = true;
    // notifyListeners();

    try {
      final count = await _repository.updateTaskStatus(taskId, newStatus);
      if (count > 0) {
        // Update local list
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          final updatedTask = StaffTask(
            id: _tasks[index].id,
            staffId: _tasks[index].staffId,
            staffName: _tasks[index].staffName,
            title: _tasks[index].title,
            description: _tasks[index].description,
            assignedDate: _tasks[index].assignedDate,
            dueDate: _tasks[index].dueDate,
            priority: _tasks[index].priority,
            status: newStatus,
            notes: _tasks[index].notes,
          );

          // Create new list to trigger UI update
          final newTasks = List<StaffTask>.from(_tasks);
          newTasks[index] = updatedTask;
          _tasks = newTasks;

          // _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      throw Exception('Failed to update task status');
    } catch (e) {
      print('❌ Task status update error: $e');
      // _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }


  Future<StaffAttendance?> getTodayAttendance(int staffId) async {
    return await _repository.getTodayAttendance(staffId);
  }

  Future<bool> markAttendance(StaffAttendance attendance) async {
    try {
      final id = await _repository.markAttendance(attendance);
      if (id > 0) {
        await loadStaffData(attendance.staffId);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Mark attendance error: $e');
      return false;
    }
  }

  Future<bool> updateCheckOut(int attendanceId, String checkOutTime) async {
    try {
      final count = await _repository.updateCheckOut(attendanceId, checkOutTime);
      if (count > 0 && _currentUser != null) {
        await loadStaffData(_currentUser!.id);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Update check-out error: $e');
      return false;
    }
  }

  // staff_provider.dart

  Future<bool> updateProfile(StaffUser user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final count = await _repository.updateUser(user);
      if (count > 0) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Update failed');
    } catch (e) {
      print('❌ Update profile error: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }



  Future<List<StaffLeave>> getStaffLeaves(int staffId) async {
    try {
      return await _repository.getStaffLeaves(staffId);
    } catch (e) {
      print('❌ Error getting staff leaves: $e');
      return [];
    }
  }

  Future<StaffLeaveBalance?> getLeaveBalance(int staffId) async {
    try {
      return await _repository.getLeaveBalance(staffId);
    } catch (e) {
      print('❌ Error getting leave balance: $e');
      return null;
    }
  }

  Future<bool> applyLeave(StaffLeave leave) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _repository.applyLeave(leave);
      if (id > 0) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Failed to apply leave');
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<StaffSchedule>> getSchedulesByStaff(int staffId) async {
    try {
      return await _repository.getSchedulesByStaff(staffId);
    } catch (e) {
      print('❌ Error getting schedules: $e');
      return [];
    }
  }

  Future<List<StaffSchedule>> getTodaysSchedules() async {
    try {
      return await _repository.getTodaysSchedules();
    } catch (e) {
      print('❌ Error getting today\'s schedules: $e');
      return [];
    }
  }

  // Add these methods to StaffProvider

// Get all leave applications (for manager)
  Future<List<StaffLeave>> getAllLeaveApplications() async {
    try {
      return await _repository.getAllLeaveApplications();
    } catch (e) {
      print('❌ Error getting all leaves: $e');
      return [];
    }
  }

// Approve leave
  Future<bool> approveLeave(int leaveId, String approvedBy) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.approveLeave(leaveId, approvedBy);
      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Approve leave error: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

// Reject leave
  Future<bool> rejectLeave(int leaveId, String reason, String rejectedBy) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.rejectLeave(leaveId, reason, rejectedBy);
      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Reject leave error: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

// Cancel leave (by staff)
  Future<bool> cancelLeave(int leaveId) async {
    try {
      final success = await _repository.cancelLeave(leaveId);
      if (success && _currentUser != null) {
        await loadStaffData(_currentUser!.id);
      }
      return success;
    } catch (e) {
      print('❌ Cancel leave error: $e');
      return false;
    }
  }



  // Add these to StaffProvider

  List<StaffTask> _allTasks = []; // Add this field

  List<StaffTask> get allTasks => _allTasks;

// Load all tasks (for manager)
  Future<void> loadAllTasks() async {
    try {
      _allTasks = await _repository.getAllTasks();
      notifyListeners();
    } catch (e) {
      print('❌ Error loading all tasks: $e');
    }
  }

// Assign new task
  Future<bool> assignTask(StaffTask task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _repository.assignTask(task);
      if (id > 0) {
        await loadAllTasks();
        if (_currentUser != null) {
          await loadStaffData(_currentUser!.id);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Failed to assign task');
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

// Delete task
  Future<bool> deleteTask(int taskId) async {
    try {
      final count = await _repository.deleteTask(taskId);
      if (count > 0) {
        await loadAllTasks();
        if (_currentUser != null) {
          await loadStaffData(_currentUser!.id);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting task: $e');
      return false;
    }
  }

// Get tasks by status
  List<StaffTask> getTasksByStatus(String status) {
    return _allTasks.where((t) => t.status == status).toList();
  }

// Get tasks by priority
  List<StaffTask> getTasksByPriority(String priority) {
    return _allTasks.where((t) => t.priority == priority).toList();
  }

// Get tasks for specific staff
  List<StaffTask> getTasksForStaff(int staffId) {
    return _allTasks.where((t) => t.staffId == staffId).toList();
  }

// Get overdue tasks
  List<StaffTask> getOverdueTasks() {
    final now = DateTime.now();
    return _allTasks.where((t) =>
    t.dueDate != null &&
        t.dueDate!.isBefore(now) &&
        t.status != 'Completed'
    ).toList();
  }

// Get task statistics
  Map<String, dynamic> getTaskStats() {
    return {
      'total': _allTasks.length,
      'pending': _allTasks.where((t) => t.status == 'Pending').length,
      'inProgress': _allTasks.where((t) => t.status == 'In Progress').length,
      'completed': _allTasks.where((t) => t.status == 'Completed').length,
      'overdue': getOverdueTasks().length,
      'highPriority': _allTasks.where((t) => t.priority == 'High').length,
    };
  }

}