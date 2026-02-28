package com.spring.hotel_management_backend.model.dto.mobile.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SyncStatusResponse {
    private Long lastSyncTime;  // এইটা Long হওয়া উচিত (timestamp)
    private String lastSyncStatus;
    private Integer pendingOperations;
    private String serverVersion;
    private Boolean syncRequired;
    private Long serverTime;
}