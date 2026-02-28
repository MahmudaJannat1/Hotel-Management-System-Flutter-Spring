import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/occupancy_report_model.dart';
import 'package:hotel_management_app/data/models/revenue_report_model.dart';

import '../../models/inventory_report_model.dart';
import '../../models/staff_report_model.dart';

class ReportApiService {
  final Dio _dio = ApiClient().dio;

  // ========== Occupancy Reports ==========

  Future<OccupancyReport> getOccupancyReport(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/occupancy',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return OccupancyReport.fromJson(response.data);
      }
      throw Exception('Failed to load occupancy report');
    } catch (e) {
      throw Exception('Failed to load occupancy report: $e');
    }
  }

  Future<OccupancyReport> getOccupancyReportByRoomType(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/occupancy/room-type',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return OccupancyReport.fromJson(response.data);
      }
      throw Exception('Failed to load occupancy report by room type');
    } catch (e) {
      throw Exception('Failed to load occupancy report by room type: $e');
    }
  }

  Future<OccupancyReport> getMonthlyOccupancyReport(int hotelId, int year) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/occupancy/monthly/$year',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        return OccupancyReport.fromJson(response.data);
      }
      throw Exception('Failed to load monthly occupancy report');
    } catch (e) {
      throw Exception('Failed to load monthly occupancy report: $e');
    }
  }

  // ========== Revenue Reports ==========

  Future<RevenueReport> getRevenueReport(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/revenue',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return RevenueReport.fromJson(response.data);
      }
      throw Exception('Failed to load revenue report');
    } catch (e) {
      throw Exception('Failed to load revenue report: $e');
    }
  }

  Future<RevenueReport> getRevenueReportByPaymentMethod(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/revenue/payment-method',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return RevenueReport.fromJson(response.data);
      }
      throw Exception('Failed to load revenue report by payment method');
    } catch (e) {
      throw Exception('Failed to load revenue report by payment method: $e');
    }
  }

  Future<RevenueReport> getRevenueReportByRoomType(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/revenue/room-type',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return RevenueReport.fromJson(response.data);
      }
      throw Exception('Failed to load revenue report by room type');
    } catch (e) {
      throw Exception('Failed to load revenue report by room type: $e');
    }
  }

  Future<RevenueReport> getYearlyRevenueComparison(int hotelId, int year) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/revenue/yearly/$year',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        return RevenueReport.fromJson(response.data);
      }
      throw Exception('Failed to load yearly revenue comparison');
    } catch (e) {
      throw Exception('Failed to load yearly revenue comparison: $e');
    }
  }


// ========== Staff Attendance Reports ==========

  Future<StaffAttendanceReport> getStaffAttendanceReport(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/staff/attendance',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return StaffAttendanceReport.fromJson(response.data);
      }
      throw Exception('Failed to load staff attendance report');
    } catch (e) {
      throw Exception('Failed to load staff attendance report: $e');
    }
  }

  Future<StaffAttendanceReport> getDepartmentAttendanceReport(
      int hotelId,
      String department,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/staff/attendance/department/$department',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return StaffAttendanceReport.fromJson(response.data);
      }
      throw Exception('Failed to load department attendance report');
    } catch (e) {
      throw Exception('Failed to load department attendance report: $e');
    }
  }

  Future<StaffAttendanceReport> getIndividualStaffReport(
      int employeeId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/staff/attendance/employee/$employeeId',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return StaffAttendanceReport.fromJson(response.data);
      }
      throw Exception('Failed to load individual staff report');
    } catch (e) {
      throw Exception('Failed to load individual staff report: $e');
    }
  }

// ========== Inventory Reports ==========

  Future<InventoryReport> getInventoryReport(int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/inventory',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        return InventoryReport.fromJson(response.data);
      }
      throw Exception('Failed to load inventory report');
    } catch (e) {
      throw Exception('Failed to load inventory report: $e');
    }
  }

  Future<InventoryReport> getInventoryReportByCategory(
      int hotelId,
      String category,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/inventory/category/$category',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        return InventoryReport.fromJson(response.data);
      }
      throw Exception('Failed to load inventory report by category');
    } catch (e) {
      throw Exception('Failed to load inventory report by category: $e');
    }
  }

  Future<InventoryReport> getInventoryTransactionReport(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.reports}/inventory/transactions',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return InventoryReport.fromJson(response.data);
      }
      throw Exception('Failed to load inventory transaction report');
    } catch (e) {
      throw Exception('Failed to load inventory transaction report: $e');
    }
  }
}