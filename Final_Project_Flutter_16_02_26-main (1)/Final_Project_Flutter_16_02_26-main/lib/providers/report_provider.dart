import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/repositories/report_repository.dart';
import 'package:hotel_management_app/data/models/occupancy_report_model.dart';
import 'package:hotel_management_app/data/models/revenue_report_model.dart';
import 'package:hotel_management_app/data/models/staff_report_model.dart';
import 'package:hotel_management_app/data/models/inventory_report_model.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  OccupancyReport? _occupancyReport;
  RevenueReport? _revenueReport;
  bool _isLoading = false;
  String? _error;
  

// Add these variables
  StaffAttendanceReport? _staffReport;
  InventoryReport? _inventoryReport;

  StaffAttendanceReport? get staffReport => _staffReport;
  InventoryReport? get inventoryReport => _inventoryReport;


  OccupancyReport? get occupancyReport => _occupancyReport;
  RevenueReport? get revenueReport => _revenueReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ========== Occupancy Reports ==========

  Future<bool> loadOccupancyReport(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _occupancyReport = await _repository.getOccupancyReport(hotelId, startDate, endDate);
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

  Future<bool> loadOccupancyReportByRoomType(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _occupancyReport = await _repository.getOccupancyReportByRoomType(hotelId, startDate, endDate);
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

  Future<bool> loadMonthlyOccupancyReport(int hotelId, int year) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _occupancyReport = await _repository.getMonthlyOccupancyReport(hotelId, year);
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

  // ========== Revenue Reports ==========

  Future<bool> loadRevenueReport(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _revenueReport = await _repository.getRevenueReport(hotelId, startDate, endDate);
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

  Future<bool> loadRevenueReportByPaymentMethod(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _revenueReport = await _repository.getRevenueReportByPaymentMethod(hotelId, startDate, endDate);
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

  Future<bool> loadRevenueReportByRoomType(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _revenueReport = await _repository.getRevenueReportByRoomType(hotelId, startDate, endDate);
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

  Future<bool> loadYearlyRevenueComparison(int hotelId, int year) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _revenueReport = await _repository.getYearlyRevenueComparison(hotelId, year);
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

  void clearReports() {
    _occupancyReport = null;
    _revenueReport = null;
    notifyListeners();
  }



// ========== Staff Attendance Reports ==========

  Future<bool> loadStaffAttendanceReport(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _staffReport = await _repository.getStaffAttendanceReport(hotelId, startDate, endDate);
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

  Future<bool> loadDepartmentAttendanceReport(
      int hotelId,
      String department,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _staffReport = await _repository.getDepartmentAttendanceReport(hotelId, department, startDate, endDate);
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

  Future<bool> loadIndividualStaffReport(
      int employeeId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _staffReport = await _repository.getIndividualStaffReport(employeeId, startDate, endDate);
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

// ========== Inventory Reports ==========

  Future<bool> loadInventoryReport(int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _inventoryReport = await _repository.getInventoryReport(hotelId);
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

  Future<bool> loadInventoryReportByCategory(int hotelId, String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _inventoryReport = await _repository.getInventoryReportByCategory(hotelId, category);
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

  Future<bool> loadInventoryTransactionReport(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _inventoryReport = await _repository.getInventoryTransactionReport(hotelId, startDate, endDate);
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
}