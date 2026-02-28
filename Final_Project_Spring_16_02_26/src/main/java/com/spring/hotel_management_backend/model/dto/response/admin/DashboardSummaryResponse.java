package com.spring.hotel_management_backend.model.dto.response.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardSummaryResponse {
    // Revenue stats
    private Double todayRevenue;
    private Double weekRevenue;
    private Double monthRevenue;
    private Double yearRevenue;
    private Double revenueGrowth;

    // Occupancy stats
    private Integer totalRooms;
    private Integer occupiedRooms;
    private Integer availableRooms;
    private Integer maintenanceRooms;
    private Double occupancyRate;
    private Double occupancyGrowth;

    // Booking stats
    private Integer todayCheckIns;
    private Integer todayCheckOuts;
    private Integer totalBookings;
    private Integer pendingBookings;
    private Integer cancelledBookings;

    // Guest stats
    private Integer totalGuests;
    private Integer newGuestsToday;
    private Integer repeatGuests;

    // Staff stats
    private Integer totalStaff;
    private Integer staffPresent;
    private Integer staffOnLeave;
    private Integer staffAbsent;

    // Alerts
    private Integer lowStockAlerts;
    private Integer pendingTasks;
    private Integer maintenanceRequests;
}
