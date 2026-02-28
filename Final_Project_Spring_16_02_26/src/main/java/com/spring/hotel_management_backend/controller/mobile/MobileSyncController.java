package com.spring.hotel_management_backend.controller.mobile;

import com.spring.hotel_management_backend.model.dto.mobile.request.PushUpdateRequest;
import com.spring.hotel_management_backend.model.dto.mobile.request.SyncRequest;
import com.spring.hotel_management_backend.model.dto.mobile.response.InitialSyncResponse;
import com.spring.hotel_management_backend.model.dto.mobile.response.PushUpdateResponse;
import com.spring.hotel_management_backend.model.dto.mobile.response.SyncStatusResponse;
import com.spring.hotel_management_backend.service.mobile.MobileSyncService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mobile/sync")
@RequiredArgsConstructor
@Tag(name = "Mobile Sync", description = "Mobile app sync APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class MobileSyncController {

    private final MobileSyncService mobileSyncService;

    @PostMapping("/initial")
    @Operation(summary = "Get initial sync data")
    public ResponseEntity<InitialSyncResponse> getInitialData(@RequestBody SyncRequest request) {
        return ResponseEntity.ok(mobileSyncService.getInitialData(request));
    }

    @PostMapping("/push")
    @Operation(summary = "Push updates to server")
    public ResponseEntity<PushUpdateResponse> pushUpdates(@RequestBody PushUpdateRequest request) {
        return ResponseEntity.ok(mobileSyncService.pushUpdates(request));
    }

    @GetMapping("/status")
    @Operation(summary = "Get sync status")
    public ResponseEntity<SyncStatusResponse> getSyncStatus(
            @RequestParam Long userId,
            @RequestParam String deviceId) {
        return ResponseEntity.ok(mobileSyncService.getSyncStatus(userId, deviceId));
    }

    @PostMapping("/resolve-conflict")
    @Operation(summary = "Resolve data conflict")
    public ResponseEntity<Boolean> resolveConflict(
            @RequestParam String entityType,
            @RequestParam Long entityId,
            @RequestBody Object clientData,
            @RequestParam Object serverData) {
        return ResponseEntity.ok(mobileSyncService.resolveConflict(entityType, entityId, clientData, serverData));
    }
}