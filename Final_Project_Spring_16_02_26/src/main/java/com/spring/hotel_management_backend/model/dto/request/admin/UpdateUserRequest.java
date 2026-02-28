package com.spring.hotel_management_backend.model.dto.request.admin;

import lombok.Data;

@Data
public class UpdateUserRequest {
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
    private String role;
    private Boolean isActive;
    private String password; // optional
}