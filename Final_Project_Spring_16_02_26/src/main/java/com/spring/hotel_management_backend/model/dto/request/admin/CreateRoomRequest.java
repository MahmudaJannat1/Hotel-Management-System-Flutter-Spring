package com.spring.hotel_management_backend.model.dto.request.admin;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class CreateRoomRequest {
    private Long hotelId;
    private String roomNumber;
    private Long roomTypeId;
    private String floor;
    private String status; // AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED
    private BigDecimal basePrice;
    private String description;
    private Integer maxOccupancy;
    private String amenities; // JSON string
    private String images; // JSON string
}