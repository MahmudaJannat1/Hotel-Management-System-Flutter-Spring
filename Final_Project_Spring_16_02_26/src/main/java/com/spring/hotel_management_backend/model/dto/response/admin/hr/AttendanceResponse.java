package com.spring.hotel_management_backend.model.dto.response.admin.hr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AttendanceResponse {
    private Long id;

    // Employee info
    private Long employeeId;
    private String employeeName;
    private String employeeIdNumber;
    private String department;

    private LocalDate date;
    private LocalTime checkInTime;
    private LocalTime checkOutTime;
    private String status;
    private Double workingHours;
    private Double overtimeHours;
    private String remarks;
    private String markedBy;
    private LocalDateTime markedAt;
    private Boolean isApproved;
    private String approvedBy;
    private LocalDateTime approvedAt;
}