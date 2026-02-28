package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.response.admin.reports.*;
import com.spring.hotel_management_backend.service.admin.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/reports")
@RequiredArgsConstructor
@Tag(name = "Reports", description = "Admin reports and analytics APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class ReportController {

    private final ReportService reportService;

    // ==================== OCCUPANCY REPORTS ====================

    @GetMapping("/occupancy")
    @Operation(summary = "Get occupancy report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OccupancyReportResponse> getOccupancyReport(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getOccupancyReport(hotelId, startDate, endDate));
    }

    @GetMapping("/occupancy/room-type")
    @Operation(summary = "Get occupancy report by room type")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OccupancyReportResponse> getOccupancyReportByRoomType(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getOccupancyReportByRoomType(hotelId, startDate, endDate));
    }

    @GetMapping("/occupancy/monthly/{year}")
    @Operation(summary = "Get monthly occupancy report for a year")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OccupancyReportResponse> getMonthlyOccupancyReport(
            @RequestParam(required = false) Long hotelId,
            @PathVariable Integer year) {
        return ResponseEntity.ok(reportService.getMonthlyOccupancyReport(hotelId, year));
    }

    // ==================== REVENUE REPORTS ====================

    @GetMapping("/revenue")
    @Operation(summary = "Get revenue report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RevenueReportResponse> getRevenueReport(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getRevenueReport(hotelId, startDate, endDate));
    }

    @GetMapping("/revenue/payment-method")
    @Operation(summary = "Get revenue report by payment method")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RevenueReportResponse> getRevenueReportByPaymentMethod(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getRevenueReportByPaymentMethod(hotelId, startDate, endDate));
    }

    @GetMapping("/revenue/room-type")
    @Operation(summary = "Get revenue report by room type")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RevenueReportResponse> getRevenueReportByRoomType(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getRevenueReportByRoomType(hotelId, startDate, endDate));
    }

    @GetMapping("/revenue/yearly/{year}")
    @Operation(summary = "Get yearly revenue comparison")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RevenueReportResponse> getYearlyRevenueComparison(
            @RequestParam(required = false) Long hotelId,
            @PathVariable Integer year) {
        return ResponseEntity.ok(reportService.getYearlyRevenueComparison(hotelId, year));
    }

    // ==================== STAFF ATTENDANCE REPORTS ====================

    @GetMapping("/staff/attendance")
    @Operation(summary = "Get staff attendance report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<StaffAttendanceReportResponse> getStaffAttendanceReport(
            @RequestParam Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        StaffAttendanceReportResponse report = reportService.getStaffAttendanceReport(hotelId, startDate, endDate);
        return ResponseEntity.ok(report);
    }


    @GetMapping("/staff/attendance/department/{department}")
    @Operation(summary = "Get department attendance report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<StaffAttendanceReportResponse> getDepartmentAttendanceReport(
            @RequestParam(required = false) Long hotelId,
            @PathVariable String department,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getDepartmentAttendanceReport(hotelId, department, startDate, endDate));
    }

    @GetMapping("/staff/attendance/employee/{employeeId}")
    @Operation(summary = "Get individual staff attendance report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<StaffAttendanceReportResponse> getIndividualStaffReport(
            @PathVariable Long employeeId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getIndividualStaffReport(employeeId, startDate, endDate));
    }

    // ==================== INVENTORY REPORTS ====================

    @GetMapping("/inventory")
    @Operation(summary = "Get inventory report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InventoryReportResponse> getInventoryReport(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(reportService.getInventoryReport(hotelId));
    }

    @GetMapping("/inventory/category/{category}")
    @Operation(summary = "Get inventory report by category")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InventoryReportResponse> getInventoryReportByCategory(
            @RequestParam(required = false) Long hotelId,
            @PathVariable String category) {
        return ResponseEntity.ok(reportService.getInventoryReportByCategory(hotelId, category));
    }

    @GetMapping("/inventory/transactions")
    @Operation(summary = "Get inventory transaction report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InventoryReportResponse> getInventoryTransactionReport(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getInventoryTransactionReport(hotelId, startDate, endDate));
    }

    // ==================== GUEST HISTORY REPORTS ====================

    @GetMapping("/guests")
    @Operation(summary = "Get guest history report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<GuestHistoryReportResponse> getGuestHistoryReport(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(reportService.getGuestHistoryReport(hotelId, startDate, endDate));
    }

    @GetMapping("/guests/nationality/{nationality}")
    @Operation(summary = "Get guest report by nationality")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<GuestHistoryReportResponse> getGuestReportByNationality(
            @RequestParam(required = false) Long hotelId,
            @PathVariable String nationality) {
        return ResponseEntity.ok(reportService.getGuestReportByNationality(hotelId, nationality));
    }

    @GetMapping("/guests/top")
    @Operation(summary = "Get top guests report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<GuestHistoryReportResponse> getTopGuestsReport(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "10") Integer limit) {
        return ResponseEntity.ok(reportService.getTopGuestsReport(hotelId, limit));
    }

    // ==================== EXPORT FUNCTIONS ====================

    @PostMapping("/export/pdf")
    @Operation(summary = "Export report to PDF")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ReportExportResponse> exportToPdf(
            @RequestBody Object reportData,
            @RequestParam String reportType) {
        return ResponseEntity.ok(reportService.exportToPdf(reportData, reportType));
    }

    @PostMapping("/export/excel")
    @Operation(summary = "Export report to Excel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ReportExportResponse> exportToExcel(
            @RequestBody Object reportData,
            @RequestParam String reportType) {
        return ResponseEntity.ok(reportService.exportToExcel(reportData, reportType));
    }

    @PostMapping("/export/csv")
    @Operation(summary = "Export report to CSV")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ReportExportResponse> exportToCsv(
            @RequestBody Object reportData,
            @RequestParam String reportType) {
        return ResponseEntity.ok(reportService.exportToCsv(reportData, reportType));
    }

    @PostMapping("/email")
    @Operation(summary = "Email report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Boolean> emailReport(
            @RequestParam String email,
            @RequestBody Object reportData,
            @RequestParam String reportType,
            @RequestParam(defaultValue = "PDF") String format) {
        return ResponseEntity.ok(reportService.emailReport(email, reportData, reportType, format));
    }
}
