package com.spring.hotel_management_backend.model.dto.request.admin.housekeeping;

import lombok.Data;

@Data
public class UpdateMaintenanceStatusRequest {
    private String status; // ASSIGNED, IN_PROGRESS, COMPLETED, CANCELLED
    private Long assignedToId; // Required for ASSIGNED status
    private String resolution; // Required for COMPLETED status
    private Double cost; // Optional
    private String verifiedBy; // Required for COMPLETED status
    private String notes;
}