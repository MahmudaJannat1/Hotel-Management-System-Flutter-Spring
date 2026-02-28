package com.spring.hotel_management_backend.model.dto.response.admin.housekeeping;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaskResponse {
    private Long id;

    // Room info
    private Long roomId;
    private String roomNumber;
    private String roomType;

    private String taskType;
    private String priority;
    private String status;

    // Assignment
    private Long assignedToId;
    private String assignedToName;

    private LocalDate scheduledDate;
    private LocalDateTime assignedAt;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;

    private String notes;
    private String completionNotes;

    private String verifiedBy;
    private LocalDateTime verifiedAt;

    private LocalDateTime createdAt;
}