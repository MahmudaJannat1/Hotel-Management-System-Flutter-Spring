package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.response.admin.*;
import com.spring.hotel_management_backend.service.admin.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/dashboard")
@RequiredArgsConstructor
@Tag(name = "Dashboard", description = "Admin dashboard and analytics APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/summary")
    @Operation(summary = "Get dashboard summary statistics")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DashboardSummaryResponse> getDashboardSummary(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(dashboardService.getDashboardSummary(hotelId));
    }

    @GetMapping("/revenue/chart")
    @Operation(summary = "Get revenue chart data")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RevenueChartResponse> getRevenueChart(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "week") String period,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(dashboardService.getRevenueChart(hotelId, period, startDate, endDate));
    }

    @GetMapping("/revenue/by-room-type")
    @Operation(summary = "Get revenue by room type")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RevenueChartResponse> getRevenueByRoomType(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(dashboardService.getRevenueByRoomType(hotelId, startDate, endDate));
    }

    @GetMapping("/revenue/by-payment-method")
    @Operation(summary = "Get revenue by payment method")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RevenueChartResponse> getRevenueByPaymentMethod(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(dashboardService.getRevenueByPaymentMethod(hotelId, startDate, endDate));
    }

    @GetMapping("/occupancy/chart")
    @Operation(summary = "Get occupancy chart data")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OccupancyChartResponse> getOccupancyChart(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "week") String period,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(dashboardService.getOccupancyChart(hotelId, period, startDate, endDate));
    }

    @GetMapping("/occupancy/by-room-type")
    @Operation(summary = "Get occupancy by room type")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OccupancyChartResponse> getOccupancyByRoomType(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(dashboardService.getOccupancyByRoomType(hotelId));
    }

    @GetMapping("/occupancy/daily")
    @Operation(summary = "Get daily occupancy")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OccupancyChartResponse> getDailyOccupancy(
            @RequestParam(required = false) Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(dashboardService.getDailyOccupancy(hotelId, date));
    }

    @GetMapping("/activities/recent")
    @Operation(summary = "Get recent activities")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RecentActivityResponse>> getRecentActivities(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "10") Integer limit) {
        return ResponseEntity.ok(dashboardService.getRecentActivities(hotelId, limit));
    }

    @GetMapping("/activities/bookings")
    @Operation(summary = "Get recent bookings")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RecentActivityResponse>> getRecentBookings(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "5") Integer limit) {
        return ResponseEntity.ok(dashboardService.getRecentBookings(hotelId, limit));
    }

    @GetMapping("/activities/checkins")
    @Operation(summary = "Get recent check-ins")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RecentActivityResponse>> getRecentCheckIns(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "5") Integer limit) {
        return ResponseEntity.ok(dashboardService.getRecentCheckIns(hotelId, limit));
    }

    @GetMapping("/activities/checkouts")
    @Operation(summary = "Get recent check-outs")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RecentActivityResponse>> getRecentCheckOuts(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "5") Integer limit) {
        return ResponseEntity.ok(dashboardService.getRecentCheckOuts(hotelId, limit));
    }

    @GetMapping("/alerts")
    @Operation(summary = "Get all alerts")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AlertResponse>> getAlerts(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(dashboardService.getAlerts(hotelId));
    }

    @GetMapping("/alerts/low-stock")
    @Operation(summary = "Get low stock alerts")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AlertResponse>> getLowStockAlerts(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(dashboardService.getLowStockAlerts(hotelId));
    }

    @GetMapping("/alerts/maintenance")
    @Operation(summary = "Get maintenance alerts")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AlertResponse>> getMaintenanceAlerts(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(dashboardService.getMaintenanceAlerts(hotelId));
    }

    @GetMapping("/trends/revenue")
    @Operation(summary = "Get revenue trend")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Double>> getRevenueTrend(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "7") Integer days) {
        return ResponseEntity.ok(dashboardService.getRevenueTrend(hotelId, days));
    }

    @GetMapping("/trends/bookings")
    @Operation(summary = "Get booking trend")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Integer>> getBookingTrend(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "7") Integer days) {
        return ResponseEntity.ok(dashboardService.getBookingTrend(hotelId, days));
    }

    @GetMapping("/trends/occupancy")
    @Operation(summary = "Get occupancy trend")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Double>> getOccupancyTrend(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(defaultValue = "7") Integer days) {
        return ResponseEntity.ok(dashboardService.getOccupancyTrend(hotelId, days));
    }
}