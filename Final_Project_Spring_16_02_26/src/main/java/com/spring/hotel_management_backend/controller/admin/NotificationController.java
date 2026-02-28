package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.notification.SendNotificationRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.notification.NotificationResponse;
import com.spring.hotel_management_backend.service.admin.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "Admin notification management APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping("/send")
    @Operation(summary = "Send notification to user(s)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<NotificationResponse> sendNotification(@RequestBody SendNotificationRequest request) {
        return new ResponseEntity<>(notificationService.sendNotification(request), HttpStatus.CREATED);
    }

    @PostMapping("/send-bulk")
    @Operation(summary = "Send bulk notification")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<NotificationResponse>> sendBulkNotification(@RequestBody SendNotificationRequest request) {
        return new ResponseEntity<>(notificationService.sendBulkNotification(request), HttpStatus.CREATED);
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get user notifications")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<NotificationResponse>> getUserNotifications(@PathVariable Long userId) {
        return ResponseEntity.ok(notificationService.getUserNotifications(userId));
    }

    @GetMapping("/user/{userId}/unread")
    @Operation(summary = "Get unread notifications")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<NotificationResponse>> getUnreadNotifications(@PathVariable Long userId) {
        return ResponseEntity.ok(notificationService.getUnreadNotifications(userId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get notification by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<NotificationResponse> getNotificationById(@PathVariable Long id) {
        return ResponseEntity.ok(notificationService.getNotificationById(id));
    }

    @GetMapping("/user/{userId}/unread-count")
    @Operation(summary = "Get unread count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Long> getUnreadCount(@PathVariable Long userId) {
        return ResponseEntity.ok(notificationService.getUnreadCount(userId));
    }

    @PutMapping("/{id}/read")
    @Operation(summary = "Mark notification as read")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/user/{userId}/read-all")
    @Operation(summary = "Mark all as read")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> markAllAsRead(@PathVariable Long userId) {
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete notification")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteNotification(@PathVariable Long id) {
        notificationService.deleteNotification(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/user/{userId}/all")
    @Operation(summary = "Delete all user notifications")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteAllUserNotifications(@PathVariable Long userId) {
        notificationService.deleteAllUserNotifications(userId);
        return ResponseEntity.noContent().build();
    }
}