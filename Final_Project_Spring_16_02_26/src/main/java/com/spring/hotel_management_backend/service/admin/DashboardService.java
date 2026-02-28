package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.response.admin.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface DashboardService {

    // Summary
    DashboardSummaryResponse getDashboardSummary(Long hotelId);

    // Revenue charts
    RevenueChartResponse getRevenueChart(Long hotelId, String period, LocalDate startDate, LocalDate endDate);
    RevenueChartResponse getRevenueByRoomType(Long hotelId, LocalDate startDate, LocalDate endDate);
    RevenueChartResponse getRevenueByPaymentMethod(Long hotelId, LocalDate startDate, LocalDate endDate);

    // Occupancy charts
    OccupancyChartResponse getOccupancyChart(Long hotelId, String period, LocalDate startDate, LocalDate endDate);
    OccupancyChartResponse getOccupancyByRoomType(Long hotelId);
    OccupancyChartResponse getDailyOccupancy(Long hotelId, LocalDate date);

    // Recent activities
    List<RecentActivityResponse> getRecentActivities(Long hotelId, Integer limit);
    List<RecentActivityResponse> getRecentBookings(Long hotelId, Integer limit);
    List<RecentActivityResponse> getRecentCheckIns(Long hotelId, Integer limit);
    List<RecentActivityResponse> getRecentCheckOuts(Long hotelId, Integer limit);

    // Alerts
    List<AlertResponse> getAlerts(Long hotelId);
    List<AlertResponse> getLowStockAlerts(Long hotelId);
    List<AlertResponse> getMaintenanceAlerts(Long hotelId);

    // Trends
    Map<String, Double> getRevenueTrend(Long hotelId, Integer days);
    Map<String, Integer> getBookingTrend(Long hotelId, Integer days);
    Map<String, Double> getOccupancyTrend(Long hotelId, Integer days);
}
