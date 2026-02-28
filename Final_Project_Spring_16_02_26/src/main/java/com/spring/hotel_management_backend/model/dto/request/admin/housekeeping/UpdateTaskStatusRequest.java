package com.spring.hotel_management_backend.model.dto.request.admin.housekeeping;

import lombok.Data;

@Data
public class UpdateTaskStatusRequest {
    private String status; // ASSIGNED, IN_PROGRESS, COMPLETED, VERIFIED, CANCELLED
    private Long assignedToId; // Required for ASSIGNED status
    private String completionNotes; // Required for COMPLETED status
    private String verifiedBy; // Required for VERIFIED status
}