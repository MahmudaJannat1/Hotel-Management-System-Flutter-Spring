package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.response.admin.reports.*;

import java.time.LocalDate;

public interface ReportService {

    // Occupancy Reports
    OccupancyReportResponse getOccupancyReport(Long hotelId, LocalDate startDate, LocalDate endDate);
    OccupancyReportResponse getOccupancyReportByRoomType(Long hotelId, LocalDate startDate, LocalDate endDate);
    OccupancyReportResponse getMonthlyOccupancyReport(Long hotelId, Integer year);

    // Revenue Reports
    RevenueReportResponse getRevenueReport(Long hotelId, LocalDate startDate, LocalDate endDate);
    RevenueReportResponse getRevenueReportByPaymentMethod(Long hotelId, LocalDate startDate, LocalDate endDate);
    RevenueReportResponse getRevenueReportByRoomType(Long hotelId, LocalDate startDate, LocalDate endDate);
    RevenueReportResponse getYearlyRevenueComparison(Long hotelId, Integer year);

    // Staff Reports
    StaffAttendanceReportResponse getStaffAttendanceReport(Long hotelId, LocalDate startDate, LocalDate endDate);
    StaffAttendanceReportResponse getDepartmentAttendanceReport(Long hotelId, String department, LocalDate startDate, LocalDate endDate);
    StaffAttendanceReportResponse getIndividualStaffReport(Long employeeId, LocalDate startDate, LocalDate endDate);

    // Inventory Reports
    InventoryReportResponse getInventoryReport(Long hotelId);
    InventoryReportResponse getInventoryReportByCategory(Long hotelId, String category);
    InventoryReportResponse getInventoryTransactionReport(Long hotelId, LocalDate startDate, LocalDate endDate);

    // Guest Reports
    GuestHistoryReportResponse getGuestHistoryReport(Long hotelId, LocalDate startDate, LocalDate endDate);
    GuestHistoryReportResponse getGuestReportByNationality(Long hotelId, String nationality);
    GuestHistoryReportResponse getTopGuestsReport(Long hotelId, Integer limit);

    // Export Functions
    ReportExportResponse exportToPdf(Object reportData, String reportType);
    ReportExportResponse exportToExcel(Object reportData, String reportType);
    ReportExportResponse exportToCsv(Object reportData, String reportType);

    // Email Reports
    Boolean emailReport(String email, Object reportData, String reportType, String format);
}
