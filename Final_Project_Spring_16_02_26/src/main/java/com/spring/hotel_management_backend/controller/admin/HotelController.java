package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateHotelRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.HotelResponse;
import com.spring.hotel_management_backend.service.admin.HotelService;
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
@RequestMapping("/api/admin/hotels")
@RequiredArgsConstructor
@Tag(name = "Hotel Management", description = "Admin hotel management APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class HotelController {

    private final HotelService hotelService;

    @PostMapping
    @Operation(summary = "Create new hotel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<HotelResponse> createHotel(@RequestBody CreateHotelRequest request) {
        HotelResponse response = hotelService.createHotel(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping
    @Operation(summary = "Get all hotels")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<HotelResponse>> getAllHotels() {
        return ResponseEntity.ok(hotelService.getAllHotels());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get hotel by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<HotelResponse> getHotelById(@PathVariable Long id) {
        return ResponseEntity.ok(hotelService.getHotelById(id));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update hotel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<HotelResponse> updateHotel(@PathVariable Long id, @RequestBody CreateHotelRequest request) {
        return ResponseEntity.ok(hotelService.updateHotel(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete hotel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteHotel(@PathVariable Long id) {
        hotelService.deleteHotel(id);
        return ResponseEntity.noContent().build();
    }
}