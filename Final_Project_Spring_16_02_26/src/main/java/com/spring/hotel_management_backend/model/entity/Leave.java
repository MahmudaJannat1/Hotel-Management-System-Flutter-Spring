package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "leaves")
@Data
public class Leave extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "employee_id")
    private Employee employee;

    private String leaveType; // ANNUAL, SICK, EMERGENCY, MATERNITY, PATERNITY, UNPAID

    private LocalDate startDate;

    private LocalDate endDate;

    private Integer totalDays;

    private String reason;

    private String status; // PENDING, APPROVED, REJECTED, CANCELLED

    private String appliedBy;

    private LocalDate appliedDate;

    private String approvedBy;

    private LocalDate approvedDate;

    private String rejectionReason;

    private String documents; // JSON string of document URLs

    private String contactDuringLeave;

    private String handoverNotes;

    private Boolean isPaid = true;
}