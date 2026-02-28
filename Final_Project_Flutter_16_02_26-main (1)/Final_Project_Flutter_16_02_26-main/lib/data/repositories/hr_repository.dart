import 'package:hotel_management_app/data/models/employee_model.dart';
import 'package:hotel_management_app/data/models/department_model.dart';
import 'package:hotel_management_app/data/models/attendance_model.dart';
import 'package:hotel_management_app/data/remote/services/hr_api_service.dart';

import '../models/leave_model.dart';

class HrRepository {
  final HrApiService _apiService = HrApiService();

  // ========== Employee Methods ==========

  Future<List<Employee>> getAllEmployees(int hotelId) async {
    try {
      return await _apiService.getAllEmployees(hotelId);
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  Future<Employee> getEmployeeById(int id) async {
    try {
      return await _apiService.getEmployeeById(id);
    } catch (e) {
      throw Exception('Failed to load employee: $e');
    }
  }

  Future<Employee> createEmployee(Map<String, dynamic> employeeData) async {
    try {
      return await _apiService.createEmployee(employeeData);
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  Future<Employee> updateEmployee(int id, Map<String, dynamic> employeeData) async {
    try {
      return await _apiService.updateEmployee(id, employeeData);
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      await _apiService.deleteEmployee(id);
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  // ========== Department Methods ==========

  Future<List<Department>> getAllDepartments(int hotelId) async {
    try {
      return await _apiService.getAllDepartments(hotelId);
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }

  // ========== Attendance Methods ==========

  Future<Attendance> markAttendance(Map<String, dynamic> attendanceData) async {
    try {
      return await _apiService.markAttendance(attendanceData);
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  Future<List<Attendance>> getAttendanceByDate(DateTime date, int hotelId) async {
    try {
      return await _apiService.getAttendanceByDate(date, hotelId);
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }

  Future<List<Attendance>> getAttendanceByEmployee(int employeeId, DateTime startDate, DateTime endDate) async {
    try {
      return await _apiService.getAttendanceByEmployee(employeeId, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }


  Future<List<Leave>> getAllLeaves(int hotelId) async {
    try {
      return await _apiService.getAllLeaves(hotelId);
    } catch (e) {
      throw Exception('Failed to load leaves: $e');
    }
  }

  Future<Leave> createLeave(Map<String, dynamic> leaveData) async {
    try {
      return await _apiService.createLeave(leaveData);
    } catch (e) {
      throw Exception('Failed to create leave: $e');
    }
  }

  Future<Leave> updateLeaveStatus(int id, String status, String? rejectionReason) async {
    try {
      return await _apiService.updateLeaveStatus(id, status, rejectionReason);
    } catch (e) {
      throw Exception('Failed to update leave status: $e');
    }
  }
}