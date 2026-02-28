package com.spring.hotel_management_backend.model.dto.mobile.request;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class PushUpdateRequest {
    private String deviceId;
    private Long userId;
    private List<SyncOperation> operations;

    @Data
    public static class SyncOperation {
        private String operationId;
        private String operationType; // CREATE, UPDATE, DELETE
        private String entityType; // BOOKING, ATTENDANCE, TASK, etc.
        private Map<String, Object> data;
        private Long timestamp;
        private String status;
    }
}