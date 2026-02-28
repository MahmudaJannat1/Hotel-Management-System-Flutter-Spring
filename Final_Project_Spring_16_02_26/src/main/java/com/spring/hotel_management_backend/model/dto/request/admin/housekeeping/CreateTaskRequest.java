package com.spring.hotel_management_backend.model.dto.request.admin.housekeeping;

import lombok.Data;
import java.time.LocalDate;

@Data
public class CreateTaskRequest {
    private Long roomId;
    private String taskType; // CLEANING, DEEP_CLEAN, LINEN_CHANGE, SUPPLY_RESTOCK, INSPECTION
    private String priority; // HIGH, MEDIUM, LOW
    private Long assignedToId;
    private LocalDate scheduledDate;
    private String notes;
}