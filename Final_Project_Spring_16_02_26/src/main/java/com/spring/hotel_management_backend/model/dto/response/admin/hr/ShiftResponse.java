package com.spring.hotel_management_backend.model.dto.response.admin.hr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShiftResponse {
    private Long id;
    private String name;
    private LocalTime startTime;
    private LocalTime endTime;
    private Double totalHours;
    private String description;
    private Double overtimeRate;
    private Boolean isActive;
    private Long hotelId;
    private Integer assignedEmployees;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}