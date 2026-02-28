package com.spring.hotel_management_backend.model.dto.request.admin;

import lombok.Data;

@Data
public class CreateHotelRequest {
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
}