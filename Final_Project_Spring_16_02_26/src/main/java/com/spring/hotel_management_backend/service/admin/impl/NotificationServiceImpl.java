package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.notification.SendNotificationRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.notification.NotificationResponse;
import com.spring.hotel_management_backend.model.entity.Notification;
import com.spring.hotel_management_backend.model.entity.User;
import com.spring.hotel_management_backend.model.enums.RoleType;
import com.spring.hotel_management_backend.repository.NotificationRepository;
import com.spring.hotel_management_backend.repository.UserRepository;
import com.spring.hotel_management_backend.service.EmailService;
import com.spring.hotel_management_backend.service.admin.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;

    @Override
    @Transactional
    public NotificationResponse sendNotification(SendNotificationRequest request) {
        List<Notification> notifications = new ArrayList<>();

        // Determine recipients
        List<Long> recipientIds = new ArrayList<>();

        if (request.getUserId() != null) {
            recipientIds.add(request.getUserId());
        } else if (request.getUserIds() != null && !request.getUserIds().isEmpty()) {
            recipientIds.addAll(request.getUserIds());
        } else if (request.getUserRole() != null) {
            // Find users by role
            List<User> users = userRepository.findByRole(RoleType.valueOf(request.getUserRole()));
            recipientIds.addAll(users.stream().map(User::getId).collect(Collectors.toList()));
        }

        for (Long userId : recipientIds) {
            User user = userRepository.findById(userId).orElse(null);
            if (user == null) continue;

            Notification notification = new Notification();
            notification.setUserId(userId);
            notification.setUserRole(user.getRole().name());
            notification.setType(request.getType());
            notification.setTitle(request.getTitle());
            notification.setMessage(request.getMessage());
            notification.setPriority(request.getPriority() != null ? request.getPriority() : "MEDIUM");
            notification.setActionUrl(request.getActionUrl());
            notification.setImageUrl(request.getImageUrl());
            notification.setSender(request.getSender() != null ? request.getSender() : "SYSTEM");
            notification.setReferenceId(request.getReferenceId());
            notification.setReferenceType(request.getReferenceType());
            notification.setExpiresAt(request.getExpiresAt());
//            notification.setHotelId(user.getHotelId());

            Notification savedNotification = notificationRepository.save(notification);
            notifications.add(savedNotification);

            // Send email if requested
            if (request.getSendEmail() != null && request.getSendEmail()) {
                try {
                    String emailBody = String.format("""
                        Title: %s
                        Message: %s
                        Type: %s
                        """, request.getTitle(), request.getMessage(), request.getType());

                    emailService.sendEmail(user.getEmail(), request.getTitle(), emailBody);

                    savedNotification.setIsEmailSent(true);
                    notificationRepository.save(savedNotification);
                } catch (Exception e) {
                    log.error("Failed to send email to: {}", user.getEmail(), e);
                }
            }

            // Send push notification would go here (Firebase)
            if (request.getSendPush() != null && request.getSendPush()) {
                // Integrate with Firebase Cloud Messaging
                savedNotification.setIsPushSent(true);
                notificationRepository.save(savedNotification);
            }
        }

        return notifications.isEmpty() ? null : mapToResponse(notifications.get(0));
    }

    @Override
    @Transactional
    public List<NotificationResponse> sendBulkNotification(SendNotificationRequest request) {
        List<NotificationResponse> responses = new ArrayList<>();

        // Send to all users of a role
        if (request.getUserRole() != null) {
            List<User> users = userRepository.findByRole(RoleType.valueOf(request.getUserRole()));
            for (User user : users) {
                request.setUserId(user.getId());
                NotificationResponse response = sendNotification(request);
                if (response != null) {
                    responses.add(response);
                }
            }
        }

        return responses;
    }

    @Override
    public List<NotificationResponse> getUserNotifications(Long userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<NotificationResponse> getUnreadNotifications(Long userId) {
        return notificationRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public NotificationResponse getNotificationById(Long id) {
        Notification notification = notificationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notification not found"));
        return mapToResponse(notification);
    }

    @Override
    @Transactional
    public void markAsRead(Long id) {
        notificationRepository.markAsRead(id, LocalDateTime.now());
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        notificationRepository.markAllAsRead(userId, LocalDateTime.now());
    }

    @Override
    @Transactional
    public void deleteNotification(Long id) {
        if (!notificationRepository.existsById(id)) {
            throw new RuntimeException("Notification not found");
        }
        notificationRepository.deleteById(id);
    }

    @Override
    @Transactional
    public void deleteAllUserNotifications(Long userId) {
        List<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
        notificationRepository.deleteAll(notifications);
    }

    @Override
    public Long getUnreadCount(Long userId) {
        return notificationRepository.countUnreadByUserId(userId);
    }

    @Override
    @Scheduled(cron = "0 0 2 * * ?") // Run at 2 AM daily
    @Transactional
    public void cleanupExpiredNotifications() {
        LocalDateTime now = LocalDateTime.now();
        List<Notification> expired = notificationRepository.findExpiredNotifications(now);
        notificationRepository.deleteAll(expired);
        log.info("Cleaned up {} expired notifications", expired.size());
    }

    private NotificationResponse mapToResponse(Notification notification) {
        String timeAgo = calculateTimeAgo(notification.getCreatedAt());

        return NotificationResponse.builder()
                .id(notification.getId())
                .userId(notification.getUserId())
                .userRole(notification.getUserRole())
                .type(notification.getType())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .priority(notification.getPriority())
                .isRead(notification.getIsRead())
                .readAt(notification.getReadAt())
                .actionUrl(notification.getActionUrl())
                .imageUrl(notification.getImageUrl())
                .sender(notification.getSender())
                .referenceId(notification.getReferenceId())
                .referenceType(notification.getReferenceType())
                .createdAt(notification.getCreatedAt())
                .timeAgo(timeAgo)
                .build();
    }

    private String calculateTimeAgo(LocalDateTime dateTime) {
        LocalDateTime now = LocalDateTime.now();
        long minutes = ChronoUnit.MINUTES.between(dateTime, now);
        long hours = ChronoUnit.HOURS.between(dateTime, now);
        long days = ChronoUnit.DAYS.between(dateTime, now);

        if (minutes < 1) return "Just now";
        if (minutes < 60) return minutes + " minutes ago";
        if (hours < 24) return hours + " hours ago";
        if (days < 30) return days + " days ago";
        return dateTime.toLocalDate().toString();
    }
}