package com.spring.hotel_management_backend.model.dto.response.admin.notification;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {
    private Long id;
    private Long userId;
    private String userRole;
    private String type;
    private String title;
    private String message;
    private String priority;
    private Boolean isRead;
    private LocalDateTime readAt;
    private String actionUrl;
    private String imageUrl;
    private String sender;
    private Long referenceId;
    private String referenceType;
    private LocalDateTime createdAt;
    private String timeAgo; // "2 minutes ago", "1 hour ago"
}