package com.spring.hotel_management_backend.model.dto.request.admin.notification;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class SendNotificationRequest {
    // For single user
    private Long userId;

    // For multiple users
    private List<Long> userIds;
    private String userRole; // ALL, ADMIN, MANAGER, STAFF, GUEST

    private String type; // BOOKING, PAYMENT, REMINDER, ALERT, PROMOTION, TASK, LEAVE
    private String title;
    private String message;
    private String priority; // HIGH, MEDIUM, LOW

    private String actionUrl;
    private String imageUrl;
    private String sender;

    private Long referenceId;
    private String referenceType;

    private Boolean sendEmail = false;
    private Boolean sendPush = false;

    private LocalDateTime expiresAt;
}