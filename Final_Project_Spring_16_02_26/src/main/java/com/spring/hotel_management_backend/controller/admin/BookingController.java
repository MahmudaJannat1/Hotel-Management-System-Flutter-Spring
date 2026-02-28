package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateBookingRequest;
import com.spring.hotel_management_backend.model.dto.request.admin.UpdateBookingStatusRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.BookingResponse;
import com.spring.hotel_management_backend.service.admin.BookingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/admin/bookings")
@RequiredArgsConstructor
@Tag(name = "Booking Management", description = "Admin booking management APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    @Operation(summary = "Create new booking")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BookingResponse> createBooking(@RequestBody CreateBookingRequest request) {
        BookingResponse response = bookingService.createBooking(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping
    @Operation(summary = "Get all bookings")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BookingResponse>> getAllBookings() {
        return ResponseEntity.ok(bookingService.getAllBookings());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get booking by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BookingResponse> getBookingById(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.getBookingById(id));
    }

    @GetMapping("/number/{bookingNumber}")
    @Operation(summary = "Get booking by booking number")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BookingResponse> getBookingByNumber(@PathVariable String bookingNumber) {
        return ResponseEntity.ok(bookingService.getBookingByNumber(bookingNumber));
    }

    @GetMapping("/guest/{guestId}")
    @Operation(summary = "Get bookings by guest")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BookingResponse>> getBookingsByGuest(@PathVariable Long guestId) {
        return ResponseEntity.ok(bookingService.getBookingsByGuest(guestId));
    }

    @GetMapping("/room/{roomId}")
    @Operation(summary = "Get bookings by room")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BookingResponse>> getBookingsByRoom(@PathVariable Long roomId) {
        return ResponseEntity.ok(bookingService.getBookingsByRoom(roomId));
    }

    @GetMapping("/hotel/{hotelId}")
    @Operation(summary = "Get bookings by hotel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BookingResponse>> getBookingsByHotel(@PathVariable Long hotelId) {
        return ResponseEntity.ok(bookingService.getBookingsByHotel(hotelId));
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "Get bookings by status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BookingResponse>> getBookingsByStatus(@PathVariable String status) {
        return ResponseEntity.ok(bookingService.getBookingsByStatus(status));
    }

    @GetMapping("/today/checkins")
    @Operation(summary = "Get today's check-ins")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BookingResponse>> getTodaysCheckIns() {
        return ResponseEntity.ok(bookingService.getTodaysCheckIns());
    }

    @GetMapping("/today/checkouts")
    @Operation(summary = "Get today's check-outs")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BookingResponse>> getTodaysCheckOuts() {
        return ResponseEntity.ok(bookingService.getTodaysCheckOuts());
    }

    @GetMapping("/range")
    @Operation(summary = "Get bookings by date range")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BookingResponse>> getDateRangeBookings(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(bookingService.getDateRangeBookings(startDate, endDate));
    }

    @PostMapping("/{id}/check-in")
    @Operation(summary = "Check-in booking")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BookingResponse> checkIn(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.checkIn(id));
    }

    @PostMapping("/{id}/check-out")
    @Operation(summary = "Check-out booking")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BookingResponse> checkOut(@PathVariable Long id, @RequestBody UpdateBookingStatusRequest request) {
        return ResponseEntity.ok(bookingService.checkOut(id, request));
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "Cancel booking")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BookingResponse> cancelBooking(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.cancelBooking(id));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update booking")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BookingResponse> updateBooking(@PathVariable Long id, @RequestBody CreateBookingRequest request) {
        return ResponseEntity.ok(bookingService.updateBooking(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete booking")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteBooking(@PathVariable Long id) {
        bookingService.deleteBooking(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/check-availability")
    @Operation(summary = "Check room availability")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Boolean> checkRoomAvailability(
            @RequestParam Long roomId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate checkIn,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate checkOut) {
        return ResponseEntity.ok(bookingService.isRoomAvailable(roomId, checkIn, checkOut));
    }
}