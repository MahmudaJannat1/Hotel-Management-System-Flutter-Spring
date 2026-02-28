package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.LoginRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.LoginResponse;

public interface AuthService {
    LoginResponse login(LoginRequest request);
}