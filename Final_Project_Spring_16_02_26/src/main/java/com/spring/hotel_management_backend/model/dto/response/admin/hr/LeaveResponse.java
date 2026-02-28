package com.spring.hotel_management_backend.model.dto.response.admin.hr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaveResponse {
    private Long id;

    // Employee info
    private Long employeeId;
    private String employeeName;
    private String employeeIdNumber;
    private String department;

    private String leaveType;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer totalDays;
    private String reason;
    private String status;

    private String appliedBy;
    private LocalDate appliedDate;
    private String approvedBy;
    private LocalDate approvedDate;
    private String rejectionReason;

    private String documents;
    private String contactDuringLeave;
    private String handoverNotes;
    private Boolean isPaid;
}