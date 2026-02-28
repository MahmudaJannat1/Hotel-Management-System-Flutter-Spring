package com.spring.hotel_management_backend.model.dto.response.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OccupancyChartResponse {
    private String chartType; // PIE, DOUGHNUT, BAR

    // For pie/doughnut chart
    private List<String> labels;
    private List<Integer> data;
    private List<String> colors;

    // For bar/line chart (daily occupancy)
    private List<String> dates;
    private List<Integer> occupiedRooms;
    private List<Integer> availableRooms;
    private List<Double> occupancyRates;

    // Room type wise
    private Map<String, Integer> roomTypeOccupancy;
    private Map<String, Double> roomTypeRevenue;

    // Summary
    private Double averageOccupancy;
    private Integer peakOccupancyDay;
    private String peakOccupancyDate;
}
