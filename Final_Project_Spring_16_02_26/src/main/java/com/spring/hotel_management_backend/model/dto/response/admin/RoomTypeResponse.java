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
public class RoomTypeResponse {
    private Long id;
    private String name;
    private String description;
    private BigDecimal basePrice;
    private Integer maxOccupancy;
    private String amenities;
    private String images;
    private Long hotelId;
    private String hotelName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}