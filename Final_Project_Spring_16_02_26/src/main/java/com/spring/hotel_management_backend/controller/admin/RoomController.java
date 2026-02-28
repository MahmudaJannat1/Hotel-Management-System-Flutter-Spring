package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateRoomRequest;
import com.spring.hotel_management_backend.model.dto.request.admin.UpdateRoomStatusRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.RoomResponse;
import com.spring.hotel_management_backend.service.admin.RoomService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/rooms")
@RequiredArgsConstructor
@Tag(name = "Room Management", description = "Admin room management APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class
RoomController {

    private final RoomService roomService;

    @Value("${file.upload-dir:uploads/rooms/}")
    private String uploadDir;

    // ========== CREATE with Image ==========
    @PostMapping(consumes = {"multipart/form-data"})
    @Operation(summary = "Create new room with image")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RoomResponse> createRoom(
            @RequestPart("roomData") CreateRoomRequest request,
            @RequestPart(value = "image", required = false) MultipartFile imageFile) {

        try {
            // Save image if provided
            if (imageFile != null && !imageFile.isEmpty()) {
                String imageUrl = saveImage(imageFile);
                request.setImages(imageUrl);
            }

            RoomResponse response = roomService.createRoom(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);

        } catch (Exception e) {
            throw new RuntimeException("Failed to create room: " + e.getMessage());
        }
    }

    // ========== UPDATE with Image ==========
    @PutMapping(value = "/{id}", consumes = {"multipart/form-data"})
    @Operation(summary = "Update room with image")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RoomResponse> updateRoom(
            @PathVariable Long id,
            @RequestPart("roomData") CreateRoomRequest request,
            @RequestPart(value = "image", required = false) MultipartFile imageFile) {

        try {
            // Save new image if provided
            if (imageFile != null && !imageFile.isEmpty()) {
                String imageUrl = saveImage(imageFile);
                request.setImages(imageUrl);
            }

            RoomResponse response = roomService.updateRoom(id, request);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            throw new RuntimeException("Failed to update room: " + e.getMessage());
        }
    }

    // ========== SERVE IMAGE ==========
    // RoomController.java e change koro:

    @GetMapping("/images/{fileName}")
    @Operation(summary = "Get room image")
// @PreAuthorize("hasRole('ADMIN')")  // 🔥 Comment out this line
    public ResponseEntity<Resource> getRoomImage(@PathVariable String fileName) {
        try {
            Path filePath = Paths.get(uploadDir).resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists() && resource.isReadable()) {
                String contentType = Files.probeContentType(filePath);
                if (contentType == null) {
                    contentType = "application/octet-stream";
                }

                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + resource.getFilename() + "\"")
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    // ========== Helper Method ==========
    private String saveImage(MultipartFile file) throws IOException {
        // Create directory if not exists
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String filename = UUID.randomUUID().toString() + extension;

        // Save file
        Path filePath = uploadPath.resolve(filename);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // Return URL - এই URL দিয়ে image access করা যাবে
        return "/api/admin/rooms/images/" + filename;
    }

    // ========== Existing CRUD Methods ==========
    @GetMapping
    @Operation(summary = "Get all rooms")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RoomResponse>> getAllRooms() {
        return ResponseEntity.ok(roomService.getAllRooms());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get room by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RoomResponse> getRoomById(@PathVariable Long id) {
        return ResponseEntity.ok(roomService.getRoomById(id));
    }

    @GetMapping("/hotel/{hotelId}")
    @Operation(summary = "Get rooms by hotel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RoomResponse>> getRoomsByHotel(@PathVariable Long hotelId) {
        return ResponseEntity.ok(roomService.getRoomsByHotel(hotelId));
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "Get rooms by status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RoomResponse>> getRoomsByStatus(@PathVariable String status) {
        return ResponseEntity.ok(roomService.getRoomsByStatus(status));
    }

    @GetMapping("/hotel/{hotelId}/available")
    @Operation(summary = "Get available rooms by hotel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RoomResponse>> getAvailableRooms(@PathVariable Long hotelId) {
        return ResponseEntity.ok(roomService.getAvailableRooms(hotelId));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Update room status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RoomResponse> updateRoomStatus(@PathVariable Long id, @RequestBody UpdateRoomStatusRequest request) {
        return ResponseEntity.ok(roomService.updateRoomStatus(id, request));
    }

    @PatchMapping("/{id}/rate")
    @Operation(summary = "Update room rate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RoomResponse> updateRoomRate(@PathVariable Long id, @RequestParam BigDecimal rate) {
        return ResponseEntity.ok(roomService.updateRoomRate(id, rate));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete room")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteRoom(@PathVariable Long id) {
        roomService.deleteRoom(id);
        return ResponseEntity.noContent().build();
    }
}