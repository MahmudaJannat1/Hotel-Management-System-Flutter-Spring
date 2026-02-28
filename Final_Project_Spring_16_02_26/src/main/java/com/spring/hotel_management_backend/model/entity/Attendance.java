package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "attendances")
@Data
public class Attendance extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "employee_id")
    private Employee employee;

    private LocalDate date;

    private LocalTime checkInTime;

    private LocalTime checkOutTime;

    private String status; // PRESENT, ABSENT, HALF_DAY, LATE, OVERTIME

    private Double workingHours;

    private Double overtimeHours;

    private String remarks;

    private String markedBy; // SYSTEM, SELF, MANAGER

    private LocalDateTime markedAt;

    private Boolean isApproved = false;

    private String approvedBy;

    private LocalDateTime approvedAt;
}