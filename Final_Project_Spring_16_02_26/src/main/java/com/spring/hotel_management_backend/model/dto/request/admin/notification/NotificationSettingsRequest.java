package com.spring.hotel_management_backend.model.dto.request.admin.notification;

import lombok.Data;
import java.util.Map;

@Data
public class NotificationSettingsRequest {
    private Long userId;
    private Map<String, Boolean> emailSettings; // "BOOKING": true, "PAYMENT": false
    private Map<String, Boolean> pushSettings;
    private Map<String, Boolean> smsSettings;
    private Boolean doNotDisturb;
    private String quietHoursStart;
    private String quietHoursEnd;
}