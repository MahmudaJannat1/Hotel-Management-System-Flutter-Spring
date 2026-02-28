package com.spring.hotel_management_backend.model.dto.response.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AlertResponse {
    private Long id;
    private String alertType; // LOW_STOCK, MAINTENANCE, TASK, BOOKING
    private String severity; // HIGH, MEDIUM, LOW
    private String title;
    private String description;
    private String action;
    private String actionUrl;
    private Boolean isRead;
    private String createdAt;
}
