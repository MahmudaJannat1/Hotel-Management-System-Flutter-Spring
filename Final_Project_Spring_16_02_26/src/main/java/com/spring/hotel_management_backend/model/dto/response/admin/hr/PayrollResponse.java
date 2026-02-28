package com.spring.hotel_management_backend.model.dto.response.admin.hr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.YearMonth;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PayrollResponse {
    private Long id;

    // Employee info
    private Long employeeId;
    private String employeeName;
    private String employeeIdNumber;
    private String department;
    private String position;

    private YearMonth month;
    private LocalDate generatedDate;
    private LocalDate paymentDate;

    // Earnings
    private Double basicSalary;
    private Double houseRent;
    private Double medicalAllowance;
    private Double conveyanceAllowance;
    private Double overtimeAmount;
    private Double bonus;
    private Double otherEarnings;
    private Double grossSalary;

    // Deductions
    private Double taxDeduction;
    private Double providentFund;
    private Double loanDeduction;
    private Double insuranceDeduction;
    private Double otherDeductions;
    private Double totalDeductions;

    private Double netSalary;

    // Working days
    private Integer totalWorkingDays;
    private Integer daysPresent;
    private Integer daysAbsent;
    private Integer daysLeave;
    private Integer overtimeHours;

    private String status;
    private String paymentMethod;
    private String bankAccountNo;
    private String transactionId;
    private String notes;

    private String generatedBy;
    private String approvedBy;
    private LocalDate approvedDate;
}