package com.spring.hotel_management_backend.model.dto.mobile.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PushUpdateResponse {
    private Boolean success;
    private String message;
    private Integer processedCount;
    private Integer failedCount;
    private List<Map<String, Object>> failedOperations;
    private Long newSyncTime;
    private String newDataVersion;
}