package com.spring.hotel_management_backend.model.dto.request.admin;

import lombok.Data;

@Data
public class UpdateRoomStatusRequest {
    private String status; // AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED
}