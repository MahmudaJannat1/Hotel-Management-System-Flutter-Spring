package com.spring.hotel_management_backend.model.dto.mobile.request;

import lombok.Data;

@Data
public class MobileLoginRequest {
    private String username;
    private String password;
    private String deviceId;
    private String deviceType; // ANDROID, IOS
    private String fcmToken; // For push notifications
}