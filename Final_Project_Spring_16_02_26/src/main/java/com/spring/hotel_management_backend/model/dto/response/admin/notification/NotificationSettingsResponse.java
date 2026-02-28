package com.spring.hotel_management_backend.model.dto.response.admin.notification;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationSettingsResponse {
    private Long userId;
    private Map<String, Boolean> emailSettings;
    private Map<String, Boolean> pushSettings;
    private Map<String, Boolean> smsSettings;
    private Boolean doNotDisturb;
    private String quietHoursStart;
    private String quietHoursEnd;
    private Long unreadCount;
}