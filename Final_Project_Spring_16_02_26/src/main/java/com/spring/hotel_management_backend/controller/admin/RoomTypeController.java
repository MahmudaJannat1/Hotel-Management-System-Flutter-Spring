package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateRoomTypeRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.RoomTypeResponse;
import com.spring.hotel_management_backend.service.admin.RoomTypeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/room-types")
@RequiredArgsConstructor
@Tag(name = "Room Type Management", description = "Admin room type management APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class RoomTypeController {

    private final RoomTypeService roomTypeService;

    @PostMapping
    @Operation(summary = "Create new room type")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RoomTypeResponse> createRoomType(@RequestBody CreateRoomTypeRequest request) {
        RoomTypeResponse response = roomTypeService.createRoomType(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping
    @Operation(summary = "Get all room types")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RoomTypeResponse>> getAllRoomTypes() {
        return ResponseEntity.ok(roomTypeService.getAllRoomTypes());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get room type by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RoomTypeResponse> getRoomTypeById(@PathVariable Long id) {
        return ResponseEntity.ok(roomTypeService.getRoomTypeById(id));
    }

    @GetMapping("/hotel/{hotelId}")
    @Operation(summary = "Get room types by hotel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RoomTypeResponse>> getRoomTypesByHotel(@PathVariable Long hotelId) {
        return ResponseEntity.ok(roomTypeService.getRoomTypesByHotel(hotelId));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update room type")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RoomTypeResponse> updateRoomType(@PathVariable Long id, @RequestBody CreateRoomTypeRequest request) {
        return ResponseEntity.ok(roomTypeService.updateRoomType(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete room type")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteRoomType(@PathVariable Long id) {
        roomTypeService.deleteRoomType(id);
        return ResponseEntity.noContent().build();
    }
}