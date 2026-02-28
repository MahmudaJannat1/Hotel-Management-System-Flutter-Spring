import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/employee_model.dart';
import 'package:hotel_management_app/data/models/department_model.dart';
import 'package:hotel_management_app/data/models/attendance_model.dart';
import 'package:hotel_management_app/data/repositories/hr_repository.dart';

import '../data/models/leave_model.dart';

class HrProvider extends ChangeNotifier {
  final HrRepository _repository = HrRepository();

  List<Employee> _employees = [];
  List<Department> _departments = [];
  List<Attendance> _attendances = [];
  List<Leave> _leaves = [];
  List<Leave> get leaves => _leaves;
  bool _isLoading = false;
  String? _error;
  Employee? _selectedEmployee;

  List<Employee> get employees => _employees;
  List<Department> get departments => _departments;
  List<Attendance> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Employee? get selectedEmployee => _selectedEmployee;


  // Statistics
  int get totalEmployees => _employees.length;
  int get activeEmployees => _employees.where((e) => e.employmentStatus == 'ACTIVE').length;
  int get onLeaveEmployees => _employees.where((e) => e.employmentStatus == 'ON_LEAVE').length;
  // Statistics
  int get pendingLeaves => _leaves.where((l) => l.status == 'pending').length;
  int get approvedLeaves => _leaves.where((l) => l.status == 'approved').length;
  int get rejectedLeaves => _leaves.where((l) => l.status == 'rejected').length;

  int get presentToday => _attendances.where((a) =>
  a.status == 'PRESENT' &&
      a.date.year == DateTime.now().year &&
      a.date.month == DateTime.now().month &&
      a.date.day == DateTime.now().day
  ).length;

  // ========== Employee Methods ==========

  Future<void> loadAllEmployees(int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await _repository.getAllEmployees(hotelId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadEmployeeById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEmployee = await _repository.getEmployeeById(id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createEmployee(Map<String, dynamic> employeeData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEmployee = await _repository.createEmployee(employeeData);
      _employees.add(newEmployee);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmployee(int id, Map<String, dynamic> employeeData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEmployee = await _repository.updateEmployee(id, employeeData);
      final index = _employees.indexWhere((e) => e.id == id);
      if (index != -1) {
        final newList = List<Employee>.from(_employees);
        newList[index] = updatedEmployee;
        _employees = newList;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEmployee(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteEmployee(id);
      _employees.removeWhere((e) => e.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ========== Department Methods ==========

  Future<void> loadAllDepartments(int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _departments = await _repository.getAllDepartments(hotelId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ========== Attendance Methods ==========

  Future<bool> markAttendance(Map<String, dynamic> attendanceData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAttendance = await _repository.markAttendance(attendanceData);
      _attendances.add(newAttendance);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAttendanceByDate(DateTime date, int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await _repository.getAttendanceByDate(date, hotelId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadAttendanceByEmployee(int employeeId, DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await _repository.getAttendanceByEmployee(employeeId, startDate, endDate);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ========== Leave Methods ==========

  Future<void> loadAllLeaves(int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leaves = await _repository.getAllLeaves(hotelId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createLeave(Map<String, dynamic> leaveData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newLeave = await _repository.createLeave(leaveData);
      _leaves.add(newLeave);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLeaveStatus(int id, String status, {String? rejectionReason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedLeave = await _repository.updateLeaveStatus(id, status, rejectionReason);
      final index = _leaves.indexWhere((l) => l.id == id);
      if (index != -1) {
        final newList = List<Leave>.from(_leaves);
        newList[index] = updatedLeave;
        _leaves = newList;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }


  // ========== Helper Methods ==========

  List<Employee> searchEmployees(String query) {
    if (query.isEmpty) return _employees;
    return _employees.where((e) {
      return e.fullName.toLowerCase().contains(query.toLowerCase()) ||
          e.employeeId.toLowerCase().contains(query.toLowerCase()) ||
          e.email.toLowerCase().contains(query.toLowerCase()) ||
          e.position.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Employee> getEmployeesByDepartment(int departmentId) {
    return _employees.where((e) => e.departmentId == departmentId).toList();
  }

  List<Employee> getEmployeesByStatus(String status) {
    return _employees.where((e) => e.employmentStatus == status).toList();
  }

  void selectEmployee(Employee employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  void clearSelection() {
    _selectedEmployee = null;
    notifyListeners();
  }
}