package com.spring.hotel_management_backend.service.mobile;

import com.spring.hotel_management_backend.model.dto.mobile.request.PushUpdateRequest;
import com.spring.hotel_management_backend.model.dto.mobile.request.SyncRequest;
import com.spring.hotel_management_backend.model.dto.mobile.response.InitialSyncResponse;
import com.spring.hotel_management_backend.model.dto.mobile.response.PushUpdateResponse;
import com.spring.hotel_management_backend.model.dto.mobile.response.SyncStatusResponse;

public interface MobileSyncService {
    InitialSyncResponse getInitialData(SyncRequest request);
    PushUpdateResponse pushUpdates(PushUpdateRequest request);
    SyncStatusResponse getSyncStatus(Long userId, String deviceId);
    Boolean resolveConflict(String entityType, Long entityId, Object clientData, Object serverData);
}