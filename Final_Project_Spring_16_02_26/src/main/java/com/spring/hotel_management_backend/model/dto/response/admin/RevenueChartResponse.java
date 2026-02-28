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
public class RevenueChartResponse {
    private String chartType; // LINE, BAR
    private List<String> labels; // Days, Months
    private List<Dataset> datasets;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Dataset {
        private String label; // Revenue, Profit
        private List<Double> data;
        private String borderColor;
        private String backgroundColor;
    }

    // Summary
    private Double totalRevenue;
    private Double averageDailyRevenue;
    private Double highestRevenue;
    private String highestRevenueDay;
    private Double lowestRevenue;
    private String lowestRevenueDay;
}
