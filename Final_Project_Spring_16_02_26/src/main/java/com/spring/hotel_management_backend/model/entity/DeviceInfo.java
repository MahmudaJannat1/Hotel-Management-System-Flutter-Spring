package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "device_info")
@Data
public class DeviceInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private String deviceId;
    private String deviceType;
    private String fcmToken;
    private LocalDateTime lastLogin;
    private LocalDateTime lastLogout;
    private Boolean isActive;
}