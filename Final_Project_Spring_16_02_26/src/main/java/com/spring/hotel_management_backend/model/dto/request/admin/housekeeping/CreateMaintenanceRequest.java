package com.spring.hotel_management_backend.model.dto.request.admin.housekeeping;

import lombok.Data;

@Data
public class CreateMaintenanceRequest {
    private Long roomId;
    private String issueType; // ELECTRICAL, PLUMBING, HVAC, FURNITURE, APPLIANCE, OTHER
    private String priority; // CRITICAL, HIGH, MEDIUM, LOW
    private String description;
    private Long reportedById;
    private String notes;
}