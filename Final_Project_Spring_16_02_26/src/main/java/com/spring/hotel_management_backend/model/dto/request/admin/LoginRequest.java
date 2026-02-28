package com.spring.hotel_management_backend.model.dto.request.admin;

import lombok.Data;

@Data
public class LoginRequest {
    private String username;
    private String password;
}