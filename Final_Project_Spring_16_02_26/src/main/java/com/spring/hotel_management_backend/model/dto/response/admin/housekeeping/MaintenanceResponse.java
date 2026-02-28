package com.spring.hotel_management_backend.model.dto.response.admin.housekeeping;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MaintenanceResponse {
    private Long id;

    // Room info
    private Long roomId;
    private String roomNumber;
    private String roomType;

    private String issueType;
    private String priority;
    private String status;
    private String description;

    // Reporter
    private Long reportedById;
    private String reportedByName;
    private LocalDateTime reportedAt;

    // Assignment
    private Long assignedToId;
    private String assignedToName;
    private LocalDateTime assignedAt;

    private LocalDateTime startedAt;
    private LocalDateTime completedAt;

    private String resolution;
    private Double cost;
    private String notes;

    private String verifiedBy;
    private LocalDateTime verifiedAt;

    private LocalDateTime createdAt;
}