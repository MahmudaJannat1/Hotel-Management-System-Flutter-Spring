package com.spring.hotel_management_backend.service.mobile;

import com.spring.hotel_management_backend.model.dto.mobile.request.MobileLoginRequest;
import com.spring.hotel_management_backend.model.dto.mobile.response.MobileLoginResponse;

public interface MobileAuthService {
    MobileLoginResponse login(MobileLoginRequest request);
    void logout(Long userId, String deviceId);
    Boolean validateToken(String token);
}