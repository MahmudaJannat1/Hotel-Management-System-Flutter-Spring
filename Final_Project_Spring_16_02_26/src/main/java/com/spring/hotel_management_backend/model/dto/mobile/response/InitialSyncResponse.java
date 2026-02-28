package com.spring.hotel_management_backend.model.dto.mobile.response;

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
public class InitialSyncResponse {
    private Long syncTime;
    private String dataVersion;
    private String message;

    // Master data
    private Map<String, Object> config;
    private List<Map<String, Object>> hotels;
    private List<Map<String, Object>> rooms;
    private List<Map<String, Object>> roomTypes;
    private List<Map<String, Object>> rates;

    // Role-specific data
    private List<Map<String, Object>> myBookings; // For guests
    private List<Map<String, Object>> myTasks; // For staff
    private List<Map<String, Object>> teamMembers; // For manager

    // Common data
    private List<Map<String, Object>> guests;
    private List<Map<String, Object>> employees;
    private List<Map<String, Object>> inventory;

    // Sync info
    private Boolean fullSyncRequired;
    private Long serverTime;
}