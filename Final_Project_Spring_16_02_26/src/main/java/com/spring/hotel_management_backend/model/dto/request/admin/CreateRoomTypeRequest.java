package com.spring.hotel_management_backend.model.dto.request.admin;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class CreateRoomTypeRequest {
    private String name;
    private String description;
    private BigDecimal basePrice;
    private Integer maxOccupancy;
    private String amenities; // JSON string
    private String images; // JSON string
    private Long hotelId;
}