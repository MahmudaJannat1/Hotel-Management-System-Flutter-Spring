package com.spring.hotel_management_backend.model.dto.response.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoomResponse {
    private Long id;
    private Long hotelId;
    private String hotelName;
    private String roomNumber;
    private Long roomTypeId;
    private String roomTypeName;
    private String floor;
    private String status;
    private BigDecimal basePrice;
    private String description;
    private Integer maxOccupancy;
    private String amenities;
    private String images;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}