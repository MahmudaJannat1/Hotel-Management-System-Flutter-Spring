package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDate;
import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "housekeeping_tasks")
@Data
public class HousekeepingTask extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "room_id")
    private Room room;

    private String taskType; // CLEANING, DEEP_CLEAN, LINEN_CHANGE, SUPPLY_RESTOCK, INSPECTION

    private String priority; // HIGH, MEDIUM, LOW

    private String status; // PENDING, ASSIGNED, IN_PROGRESS, COMPLETED, VERIFIED, CANCELLED

    @ManyToOne
    @JoinColumn(name = "assigned_to")
    private Employee assignedTo;

    private LocalDate scheduledDate;

    private LocalDateTime assignedAt;

    private LocalDateTime startedAt;

    private LocalDateTime completedAt;

    private String notes;

    private String completionNotes;

    private String verifiedBy;

    private LocalDateTime verifiedAt;

    private Long hotelId;
}