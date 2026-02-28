package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "notifications")
@Data
public class Notification extends BaseEntity {

    private Long userId; // Recipient user ID

    private String userRole; // ADMIN, MANAGER, STAFF, GUEST

    private String type; // BOOKING, PAYMENT, REMINDER, ALERT, PROMOTION, TASK, LEAVE

    private String title;

    @Column(length = 1000)
    private String message;

    private String priority; // HIGH, MEDIUM, LOW

    private Boolean isRead = false;

    private LocalDateTime readAt;

    private String actionUrl; // Deep link to relevant page

    private String imageUrl;

    private String sender; // SYSTEM, ADMIN, MANAGER

    private Long referenceId; // Booking ID, Task ID, etc.

    private String referenceType; // BOOKING, TASK, LEAVE, etc.

    private Boolean isEmailSent = false;

    private Boolean isPushSent = false;

    private LocalDateTime expiresAt;

    private Long hotelId;
}