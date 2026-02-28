package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "sync_logs")
@Data
public class SyncLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private String deviceId;
    private String syncType; // INITIAL, PULL, PUSH
    private LocalDateTime requestTime;
    private LocalDateTime responseTime;
    private String status; // SUCCESS, FAILED, PARTIAL
    private Integer recordsSent;
    private Integer recordsReceived;
    private Integer recordsProcessed;
    private Integer recordsFailed;
    private String errorMessage;
}