package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;
import java.time.YearMonth;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "payrolls")
@Data
public class Payroll extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "employee_id")
    private Employee employee;

    private YearMonth month; // Format: 2024-01

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

    private String status; // DRAFT, GENERATED, PAID, CANCELLED

    private String paymentMethod; // BANK, CASH, CHEQUE

    private String bankAccountNo;

    private String transactionId;

    private String notes;

    private String generatedBy;

    private String approvedBy;

    private LocalDate approvedDate;
}