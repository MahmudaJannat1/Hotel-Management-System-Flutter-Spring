package com.spring.hotel_management_backend.model.dto.response.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecentActivityResponse {
    private Long id;
    private String activityType; // BOOKING, CHECK_IN, CHECK_OUT, PAYMENT, etc.
    private String description;
    private String status;
    private String userName;
    private String userRole;
    private String guestName;
    private String roomNumber;
    private Double amount;
    private LocalDateTime timestamp;
    private String icon;
    private String color;
}
