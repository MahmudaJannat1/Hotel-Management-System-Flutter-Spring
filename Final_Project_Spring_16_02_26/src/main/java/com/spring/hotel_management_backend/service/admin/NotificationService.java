package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.notification.SendNotificationRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.notification.NotificationResponse;
import com.spring.hotel_management_backend.model.dto.response.admin.notification.NotificationSettingsResponse;

import java.util.List;

public interface NotificationService {

    // Send notifications
    NotificationResponse sendNotification(SendNotificationRequest request);
    List<NotificationResponse> sendBulkNotification(SendNotificationRequest request);

    // Get notifications
    List<NotificationResponse> getUserNotifications(Long userId);
    List<NotificationResponse> getUnreadNotifications(Long userId);
    NotificationResponse getNotificationById(Long id);

    // Mark as read
    void markAsRead(Long id);
    void markAllAsRead(Long userId);

    // Delete
    void deleteNotification(Long id);
    void deleteAllUserNotifications(Long userId);

    // Count
    Long getUnreadCount(Long userId);

    // Cleanup
    void cleanupExpiredNotifications();
}