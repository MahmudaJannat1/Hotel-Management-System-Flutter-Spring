package com.spring.hotel_management_backend.model.dto.request.admin;

import lombok.Data;

@Data
public class CreateUserRequest {
    private String username;
    private String email;
    private String password;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private String role;  // ADMIN, MANAGER, STAFF, GUEST
    private Long hotelId; // optional
}