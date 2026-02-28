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
public class OccupancyReportResponse {

    private String reportType;
    private LocalDate startDate;
    private LocalDate endDate;
    private String generatedAt;

    // Summary
    private Integer totalRooms;
    private Integer totalOccupiedRooms;
    private Integer totalAvailableRooms;
    private Integer totalMaintenanceRooms;
    private Double averageOccupancyRate;

    // Daily breakdown
    private List<DailyOccupancy> dailyOccupancy;

    // Room type wise
    private Map<String, RoomTypeOccupancy> roomTypeStats;

    // Monthly summary
    private Map<String, MonthlyOccupancy> monthlyStats;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyOccupancy {
        private LocalDate date;
        private Integer occupiedRooms;
        private Integer availableRooms;
        private Integer maintenanceRooms;
        private Double occupancyRate;
        private Double revenue;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RoomTypeOccupancy {
        private String roomTypeName;
        private Integer totalRooms;
        private Integer occupiedRooms;
        private Double occupancyRate;
        private Double averageRate;
        private Double totalRevenue;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MonthlyOccupancy {
        private String month;
        private Integer totalNights;
        private Double averageRate;
        private Double totalRevenue;
        private Double occupancyRate;
    }
}