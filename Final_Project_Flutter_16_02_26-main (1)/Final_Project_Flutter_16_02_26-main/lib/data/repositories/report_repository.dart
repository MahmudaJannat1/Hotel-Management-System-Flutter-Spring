import 'package:hotel_management_app/data/remote/services/report_api_service.dart';
import 'package:hotel_management_app/data/models/occupancy_report_model.dart';
import 'package:hotel_management_app/data/models/revenue_report_model.dart';
import 'package:hotel_management_app/data/models/staff_report_model.dart';
import 'package:hotel_management_app/data/models/inventory_report_model.dart';


class ReportRepository {
  final ReportApiService _apiService = ReportApiService();

  // ========== Occupancy Reports ==========

  Future<OccupancyReport> getOccupancyReport(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      return await _apiService.getOccupancyReport(hotelId, startDate, endDate);
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
      return await _apiService.getOccupancyReportByRoomType(hotelId, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to load occupancy report by room type: $e');
    }
  }

  Future<OccupancyReport> getMonthlyOccupancyReport(int hotelId, int year) async {
    try {
      return await _apiService.getMonthlyOccupancyReport(hotelId, year);
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
      return await _apiService.getRevenueReport(hotelId, startDate, endDate);
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
      return await _apiService.getRevenueReportByPaymentMethod(hotelId, startDate, endDate);
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
      return await _apiService.getRevenueReportByRoomType(hotelId, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to load revenue report by room type: $e');
    }
  }

  Future<RevenueReport> getYearlyRevenueComparison(int hotelId, int year) async {
    try {
      return await _apiService.getYearlyRevenueComparison(hotelId, year);
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
      return await _apiService.getStaffAttendanceReport(hotelId, startDate, endDate);
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
      return await _apiService.getDepartmentAttendanceReport(hotelId, department, startDate, endDate);
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
      return await _apiService.getIndividualStaffReport(employeeId, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to load individual staff report: $e');
    }
  }

// ========== Inventory Reports ==========

  Future<InventoryReport> getInventoryReport(int hotelId) async {
    try {
      return await _apiService.getInventoryReport(hotelId);
    } catch (e) {
      throw Exception('Failed to load inventory report: $e');
    }
  }

  Future<InventoryReport> getInventoryReportByCategory(
      int hotelId,
      String category,
      ) async {
    try {
      return await _apiService.getInventoryReportByCategory(hotelId, category);
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
      return await _apiService.getInventoryTransactionReport(hotelId, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to load inventory transaction report: $e');
    }
  }
}