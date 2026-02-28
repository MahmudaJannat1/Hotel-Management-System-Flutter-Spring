package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.entity.Guest;
import com.spring.hotel_management_backend.repository.GuestRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/admin/guests")
@RequiredArgsConstructor
@Tag(name = "Guest Management", description = "Admin guest management APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class GuestController {

    private final GuestRepository guestRepository;

    @PostMapping
    @Operation(summary = "Create new guest")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Guest> createGuest(@RequestBody Guest guest) {
        // Check if email exists
        if (guest.getEmail() != null && guestRepository.existsByEmail(guest.getEmail())) {
            throw new RuntimeException("Email already exists: " + guest.getEmail());
        }

        // Check if phone exists
        if (guest.getPhone() != null && guestRepository.existsByPhone(guest.getPhone())) {
            throw new RuntimeException("Phone already exists: " + guest.getPhone());
        }

        // Check if ID proof exists
        if (guest.getIdProofNumber() != null && guestRepository.existsByIdProofNumber(guest.getIdProofNumber())) {
            throw new RuntimeException("ID proof number already exists: " + guest.getIdProofNumber());
        }

        Guest savedGuest = guestRepository.save(guest);
        return new ResponseEntity<>(savedGuest, HttpStatus.CREATED);
    }

    @GetMapping
    @Operation(summary = "Get all guests")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Guest>> getAllGuests() {
        return ResponseEntity.ok(guestRepository.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get guest by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Guest> getGuestById(@PathVariable Long id) {
        Guest guest = guestRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Guest not found with id: " + id));
        return ResponseEntity.ok(guest);
    }

    @GetMapping("/email/{email}")
    @Operation(summary = "Get guest by email")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Guest> getGuestByEmail(@PathVariable String email) {
        Guest guest = guestRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Guest not found with email: " + email));
        return ResponseEntity.ok(guest);
    }

    @GetMapping("/phone/{phone}")
    @Operation(summary = "Get guest by phone")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Guest> getGuestByPhone(@PathVariable String phone) {
        Guest guest = guestRepository.findByPhone(phone)
                .orElseThrow(() -> new RuntimeException("Guest not found with phone: " + phone));
        return ResponseEntity.ok(guest);
    }

    @GetMapping("/search")
    @Operation(summary = "Search guests by name")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Guest>> searchGuests(@RequestParam String name) {
        return ResponseEntity.ok(guestRepository.searchByName(name));
    }

    @GetMapping("/recent")
    @Operation(summary = "Get recent guests")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Guest>> getRecentGuests() {
        return ResponseEntity.ok(guestRepository.findRecentGuests());
    }

    @GetMapping("/today/checkins")
    @Operation(summary = "Get today's check-in guests")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Guest>> getTodayCheckIns() {
        return ResponseEntity.ok(guestRepository.findTodayCheckIns(LocalDate.now()));
    }

    @GetMapping("/today/checkouts")
    @Operation(summary = "Get today's check-out guests")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Guest>> getTodayCheckOuts() {
        return ResponseEntity.ok(guestRepository.findTodayCheckOuts(LocalDate.now()));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update guest")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Guest> updateGuest(@PathVariable Long id, @RequestBody Guest guestDetails) {
        Guest guest = guestRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Guest not found with id: " + id));

        guest.setFirstName(guestDetails.getFirstName());
        guest.setLastName(guestDetails.getLastName());
        guest.setEmail(guestDetails.getEmail());
        guest.setPhone(guestDetails.getPhone());
        guest.setAddress(guestDetails.getAddress());
        guest.setCity(guestDetails.getCity());
        guest.setCountry(guestDetails.getCountry());
        guest.setIdProofType(guestDetails.getIdProofType());
        guest.setIdProofNumber(guestDetails.getIdProofNumber());
        guest.setNationality(guestDetails.getNationality());
        guest.setDateOfBirth(guestDetails.getDateOfBirth());
        guest.setGender(guestDetails.getGender());

        Guest updatedGuest = guestRepository.save(guest);
        return ResponseEntity.ok(updatedGuest);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete guest")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteGuest(@PathVariable Long id) {
        if (!guestRepository.existsById(id)) {
            throw new RuntimeException("Guest not found with id: " + id);
        }
        guestRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}