package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "maintenance_requests")
@Data
public class MaintenanceRequest extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "room_id")
    private Room room;

    private String issueType; // ELECTRICAL, PLUMBING, HVAC, FURNITURE, APPLIANCE, OTHER

    private String priority; // CRITICAL, HIGH, MEDIUM, LOW

    private String status; // REPORTED, ASSIGNED, IN_PROGRESS, COMPLETED, CANCELLED

    private String description;

    @ManyToOne
    @JoinColumn(name = "reported_by")
    private Employee reportedBy;

    private LocalDateTime reportedAt;

    @ManyToOne
    @JoinColumn(name = "assigned_to")
    private Employee assignedTo;

    private LocalDateTime assignedAt;

    private LocalDateTime startedAt;

    private LocalDateTime completedAt;

    private String resolution;

    private String notes;

    private Double cost;

    private String verifiedBy;

    private LocalDateTime verifiedAt;

    private Long hotelId;
}