package com.spring.hotel_management_backend.model.dto.response.admin.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RevenueReportResponse {

    private String reportType;
    private LocalDate startDate;
    private LocalDate endDate;
    private String generatedAt;

    // Summary
    private Double totalRevenue;
    private Double totalRoomRevenue;
    private Double totalFnbRevenue; // Food & Beverage
    private Double totalOtherRevenue;
    private Double averageDailyRate;
    private Double revenuePerAvailableRoom;
    private Integer totalBookings;
    private Integer cancelledBookings;
    private Integer noShowBookings;

    // Daily breakdown
    private List<DailyRevenue> dailyRevenue;

    // Payment method wise
    private Map<String, Double> paymentMethodRevenue;

    // Room type wise
    private Map<String, Double> roomTypeRevenue;

    // Monthly comparison
    private Map<String, MonthlyRevenue> monthlyRevenue;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyRevenue {
        private LocalDate date;
        private Double roomRevenue;
        private Double fnbRevenue;
        private Double otherRevenue;
        private Double totalRevenue;
        private Integer bookings;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MonthlyRevenue {
        private String month;
        private Double revenue;
        private Double previousYearRevenue;
        private Double growthPercentage;
        private Integer bookings;
    }
}