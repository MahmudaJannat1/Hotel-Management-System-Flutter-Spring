package com.spring.hotel_management_backend.model.dto.mobile.request;

import lombok.Data;

@Data
public class SyncRequest {
    private Long lastSyncTime;
    private String deviceId;
    private String dataVersion;
    private Long userId;
}