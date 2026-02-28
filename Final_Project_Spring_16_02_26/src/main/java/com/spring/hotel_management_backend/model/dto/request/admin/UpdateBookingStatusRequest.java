package com.spring.hotel_management_backend.model.dto.request.admin;

import lombok.Data;

@Data
public class UpdateBookingStatusRequest {
    private String status; // CHECKED_IN, CHECKED_OUT, CANCELLED
}