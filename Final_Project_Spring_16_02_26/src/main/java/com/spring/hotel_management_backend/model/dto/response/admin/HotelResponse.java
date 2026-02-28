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
public class HotelResponse {
    private Long id;
    private String name;
    private String address;
    private String city;
    private String country;
    private String phone;
    private String email;
    private String website;
    private Integer starRating;
    private String description;
    private String logoUrl;
    private String checkInTime;
    private String checkOutTime;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}