package com.spring.hotel_management_backend.service.mobile.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.spring.hotel_management_backend.model.dto.mobile.request.PushUpdateRequest;
import com.spring.hotel_management_backend.model.dto.mobile.request.SyncRequest;
import com.spring.hotel_management_backend.model.dto.mobile.response.InitialSyncResponse;
import com.spring.hotel_management_backend.model.dto.mobile.response.PushUpdateResponse;
import com.spring.hotel_management_backend.model.dto.mobile.response.SyncStatusResponse;
import com.spring.hotel_management_backend.model.entity.*;
import com.spring.hotel_management_backend.repository.*;
import com.spring.hotel_management_backend.service.mobile.MobileSyncService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MobileSyncServiceImpl implements MobileSyncService {

    private final UserRepository userRepository;
    private final HotelRepository hotelRepository;
    private final RoomRepository roomRepository;
    private final RoomTypeRepository roomTypeRepository;
    private final BookingRepository bookingRepository;
    private final GuestRepository guestRepository;
    private final EmployeeRepository employeeRepository;
    private final InventoryRepository inventoryRepository;
    private final SyncLogRepository syncLogRepository;
    private final ObjectMapper objectMapper;

    @Override
    public InitialSyncResponse getInitialData(SyncRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Long hotelId = user.getHotel() != null ? user.getHotel().getId() : null;

        // Log sync request
        SyncLog syncLog = new SyncLog();
        syncLog.setUserId(user.getId());
        syncLog.setDeviceId(request.getDeviceId());
        syncLog.setSyncType("INITIAL");
        syncLog.setRequestTime(LocalDateTime.now());

        // Build response based on user role
        InitialSyncResponse.InitialSyncResponseBuilder responseBuilder = InitialSyncResponse.builder()
                .syncTime(System.currentTimeMillis())
                .dataVersion("v1.0_" + System.currentTimeMillis())
                .serverTime(System.currentTimeMillis())
                .fullSyncRequired(true)
                .config(getHotelConfig(hotelId));

        // Common data for all roles
        responseBuilder.hotels(getHotelsData(hotelId));
        responseBuilder.rooms(getRoomsData(hotelId));
        responseBuilder.roomTypes(getRoomTypesData(hotelId));
        responseBuilder.guests(getGuestsData(hotelId));

        // Role-specific data
        switch (user.getRole()) {
            case ADMIN:
                responseBuilder.employees(getEmployeesData(hotelId));
                responseBuilder.inventory(getInventoryData(hotelId));
                break;

            case MANAGER:
                responseBuilder.teamMembers(getTeamMembersData(hotelId));
                responseBuilder.myTasks(getManagerTasks(hotelId));
                responseBuilder.inventory(getInventoryData(hotelId));
                break;

            case STAFF:
                responseBuilder.myTasks(getStaffTasks(user.getId()));
                break;

            case GUEST:
                responseBuilder.myBookings(getGuestBookings(user.getId()));
                break;
        }

        // Update sync log
        syncLog.setResponseTime(LocalDateTime.now());
        syncLog.setStatus("SUCCESS");
        syncLog.setRecordsSent(estimateRecordCount(responseBuilder));
        syncLogRepository.save(syncLog);

        return responseBuilder.build();
    }

    @Override
    public PushUpdateResponse pushUpdates(PushUpdateRequest request) {
        List<Map<String, Object>> failedOperations = new ArrayList<>();
        int successCount = 0;
        int failCount = 0;

        for (PushUpdateRequest.SyncOperation operation : request.getOperations()) {
            try {
                processOperation(operation, request.getUserId());
                successCount++;
            } catch (Exception e) {
                failCount++;
                Map<String, Object> failedOp = new HashMap<>();
                failedOp.put("operationId", operation.getOperationId());
                failedOp.put("error", e.getMessage());
                failedOperations.add(failedOp);
            }
        }

        // Log sync
        SyncLog syncLog = new SyncLog();
        syncLog.setUserId(request.getUserId());
        syncLog.setDeviceId(request.getDeviceId());
        syncLog.setSyncType("PUSH");
        syncLog.setRequestTime(LocalDateTime.now());
        syncLog.setResponseTime(LocalDateTime.now());
        syncLog.setStatus(failCount == 0 ? "SUCCESS" : "PARTIAL");
        syncLog.setRecordsReceived(request.getOperations().size());
        syncLog.setRecordsProcessed(successCount);
        syncLog.setRecordsFailed(failCount);
        syncLogRepository.save(syncLog);

        return PushUpdateResponse.builder()
                .success(failCount == 0)
                .message(failCount == 0 ? "All operations synced successfully" : failCount + " operations failed")
                .processedCount(successCount)
                .failedCount(failCount)
                .failedOperations(failedOperations)
                .newSyncTime(System.currentTimeMillis())
                .newDataVersion("v1.0_" + System.currentTimeMillis())
                .build();
    }

    @Override
    public SyncStatusResponse getSyncStatus(Long userId, String deviceId) {
        SyncLog lastSync = syncLogRepository.findTopByUserIdAndDeviceIdOrderByRequestTimeDesc(userId, deviceId);

        Long pendingCount = syncLogRepository.countPendingByUserIdAndDeviceId(userId, deviceId);

        return SyncStatusResponse.builder()
                .lastSyncTime(lastSync != null ? lastSync.getResponseTime().toEpochSecond(java.time.ZoneOffset.UTC) * 1000 : null)
                .lastSyncStatus(lastSync != null ? lastSync.getStatus() : "NO_SYNC")
                .pendingOperations(pendingCount != null ? pendingCount.intValue() : 0)
                .serverVersion("v1.0")
                .syncRequired(pendingCount != null && pendingCount > 0)
                .serverTime(System.currentTimeMillis())
                .build();
    }

    @Override
    public Boolean resolveConflict(String entityType, Long entityId, Object clientData, Object serverData) {
        // Implement conflict resolution logic
        // Default: server wins
        return true;
    }

    // Private helper methods for data preparation

    private Map<String, Object> getHotelConfig(Long hotelId) {
        Map<String, Object> config = new HashMap<>();
        if (hotelId != null) {
            Hotel hotel = hotelRepository.findById(hotelId).orElse(null);
            if (hotel != null) {
                config.put("hotelName", hotel.getName());
                config.put("checkInTime", hotel.getCheckInTime());
                config.put("checkOutTime", hotel.getCheckOutTime());
                config.put("currency", "BDT");
                config.put("taxRate", 15);
            }
        }
        return config;
    }

    private List<Map<String, Object>> getHotelsData(Long hotelId) {
        List<Hotel> hotels;
        if (hotelId != null) {
            hotels = hotelRepository.findById(hotelId).stream().collect(Collectors.toList());
        } else {
            hotels = hotelRepository.findAll();
        }
        return hotels.stream().map(this::convertHotelToMap).collect(Collectors.toList());
    }

    private List<Map<String, Object>> getRoomsData(Long hotelId) {
        if (hotelId != null) {
            Hotel hotel = hotelRepository.findById(hotelId).orElse(null);
            if (hotel != null) {
                return roomRepository.findByHotel(hotel).stream()
                        .map(this::convertRoomToMap)
                        .collect(Collectors.toList());
            }
        }
        return roomRepository.findAll().stream()
                .map(this::convertRoomToMap)
                .collect(Collectors.toList());
    }

    private List<Map<String, Object>> getRoomTypesData(Long hotelId) {
        if (hotelId != null) {
            return roomTypeRepository.findByHotelId(hotelId).stream()
                    .map(this::convertRoomTypeToMap)
                    .collect(Collectors.toList());
        }
        return roomTypeRepository.findAll().stream()
                .map(this::convertRoomTypeToMap)
                .collect(Collectors.toList());
    }

    private List<Map<String, Object>> getGuestsData(Long hotelId) {
        // This is simplified - you might want to filter by hotel
        return guestRepository.findAll().stream()
                .map(this::convertGuestToMap)
                .collect(Collectors.toList());
    }

    private List<Map<String, Object>> getEmployeesData(Long hotelId) {
        // Implement employee fetching
        return new ArrayList<>();
    }

    private List<Map<String, Object>> getInventoryData(Long hotelId) {
        // Implement inventory fetching
        return new ArrayList<>();
    }

    private List<Map<String, Object>> getTeamMembersData(Long hotelId) {
        // Implement team members fetching
        return new ArrayList<>();
    }

    private List<Map<String, Object>> getManagerTasks(Long hotelId) {
        // Implement manager tasks
        return new ArrayList<>();
    }

    private List<Map<String, Object>> getStaffTasks(Long userId) {
        // Implement staff tasks
        return new ArrayList<>();
    }

    private List<Map<String, Object>> getGuestBookings(Long userId) {
        // Implement guest bookings
        return new ArrayList<>();
    }

    private void processOperation(PushUpdateRequest.SyncOperation operation, Long userId) {
        switch (operation.getEntityType()) {
            case "BOOKING":
                processBookingOperation(operation);
                break;
            case "ATTENDANCE":
                processAttendanceOperation(operation);
                break;
            case "TASK":
                processTaskOperation(operation);
                break;
            // Add more cases as needed
        }
    }

    private void processBookingOperation(PushUpdateRequest.SyncOperation operation) {
        // Implement booking operation processing
    }

    private void processAttendanceOperation(PushUpdateRequest.SyncOperation operation) {
        // Implement attendance operation processing
    }

    private void processTaskOperation(PushUpdateRequest.SyncOperation operation) {
        // Implement task operation processing
    }

    // Conversion methods
    private Map<String, Object> convertHotelToMap(Hotel hotel) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", hotel.getId());
        map.put("name", hotel.getName());
        map.put("address", hotel.getAddress());
        map.put("city", hotel.getCity());
        map.put("phone", hotel.getPhone());
        map.put("email", hotel.getEmail());
        map.put("starRating", hotel.getStarRating());
        map.put("checkInTime", hotel.getCheckInTime());
        map.put("checkOutTime", hotel.getCheckOutTime());
        return map;
    }

    private Map<String, Object> convertRoomToMap(Room room) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", room.getId());
        map.put("roomNumber", room.getRoomNumber());
        map.put("roomTypeId", room.getRoomType() != null ? room.getRoomType().getId() : null);
        map.put("roomTypeName", room.getRoomType() != null ? room.getRoomType().getName() : null);
        map.put("floor", room.getFloor());
        map.put("status", room.getStatus());
        map.put("basePrice", room.getBasePrice());
        map.put("maxOccupancy", room.getMaxOccupancy());
        map.put("amenities", room.getAmenities());
        map.put("images", room.getImages());
        return map;
    }

    private Map<String, Object> convertRoomTypeToMap(RoomType roomType) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", roomType.getId());
        map.put("name", roomType.getName());
        map.put("description", roomType.getDescription());
        map.put("basePrice", roomType.getBasePrice());
        map.put("maxOccupancy", roomType.getMaxOccupancy());
        map.put("amenities", roomType.getAmenities());
        map.put("images", roomType.getImages());
        return map;
    }

    private Map<String, Object> convertGuestToMap(Guest guest) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", guest.getId());
        map.put("firstName", guest.getFirstName());
        map.put("lastName", guest.getLastName());
        map.put("email", guest.getEmail());
        map.put("phone", guest.getPhone());
        map.put("address", guest.getAddress());
        map.put("idProofType", guest.getIdProofType());
        map.put("idProofNumber", guest.getIdProofNumber());
        return map;
    }

    private int estimateRecordCount(InitialSyncResponse.InitialSyncResponseBuilder builder) {
        // This is a placeholder - implement actual counting
        return 100;
    }
}