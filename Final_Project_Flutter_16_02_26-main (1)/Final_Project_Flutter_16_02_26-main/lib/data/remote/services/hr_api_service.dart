import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/employee_model.dart';
import 'package:hotel_management_app/data/models/department_model.dart';
import 'package:hotel_management_app/data/models/attendance_model.dart';
import 'package:hotel_management_app/data/models/leave_model.dart';

class HrApiService {
  final Dio _dio = ApiClient().dio;

  // ========== Employee Endpoints ==========

  Future<List<Employee>> getAllEmployees(int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.hr}/employees',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  Future<Employee> getEmployeeById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.hr}/employees/$id');

      if (response.statusCode == 200) {
        return Employee.fromJson(response.data);
      }
      throw Exception('Employee not found');
    } catch (e) {
      throw Exception('Failed to load employee: $e');
    }
  }

  Future<Employee> createEmployee(Map<String, dynamic> employeeData) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.hr}/employees',
        data: employeeData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Employee.fromJson(response.data);
      }
      throw Exception('Failed to create employee');
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  Future<Employee> updateEmployee(
      int id, Map<String, dynamic> employeeData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.hr}/employees/$id',
        data: employeeData,
      );

      if (response.statusCode == 200) {
        return Employee.fromJson(response.data);
      }
      throw Exception('Failed to update employee');
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.hr}/employees/$id');
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  // ========== Department Endpoints ==========

  Future<List<Department>> getAllDepartments(int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.hr}/departments',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Department.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }

  // ========== Attendance Endpoints ==========

  Future<Attendance> markAttendance(
      Map<String, dynamic> attendanceData) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.hr}/attendance',
        data: attendanceData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Attendance.fromJson(response.data);
      }
      throw Exception('Failed to mark attendance');
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // ✅ Updated attendance date API (clean version)
  Future<List<Attendance>> getAttendanceByDate(
      DateTime date, int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.hr}/attendance/date',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
          'hotelId': hotelId,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Attendance.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }

  Future<List<Attendance>> getAttendanceByEmployee(
      int employeeId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.hr}/attendance/employee/$employeeId',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Attendance.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }

  // ========== LEAVE Methods ==========

  Future<List<Leave>> getAllLeaves(int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.hr}/leaves',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Leave.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load leaves: $e');
    }
  }

  Future<Leave> createLeave(Map<String, dynamic> leaveData) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.hr}/leaves',
        data: leaveData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Leave.fromJson(response.data);
      }
      throw Exception('Failed to create leave');
    } catch (e) {
      throw Exception('Failed to create leave: $e');
    }
  }

  Future<Leave> updateLeaveStatus(
      int id, String status, String? rejectionReason) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.hr}/leaves/$id',
        data: {
          'status': status.toUpperCase(),
          if (rejectionReason != null)
            'rejectionReason': rejectionReason,
        },
      );

      if (response.statusCode == 200) {
        return Leave.fromJson(response.data);
      }
      throw Exception('Failed to update leave status');
    } catch (e) {
      throw Exception('Failed to update leave status: $e');
    }
  }
}