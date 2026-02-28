package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Guest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface GuestRepository extends JpaRepository<Guest, Long> {

    // Find by email
    Optional<Guest> findByEmail(String email);

    // Find by phone
    Optional<Guest> findByPhone(String phone);

    // Find by ID proof
    Optional<Guest> findByIdProofNumber(String idProofNumber);

    // Search guests by name
    @Query("SELECT g FROM Guest g WHERE LOWER(g.firstName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR LOWER(g.lastName) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    List<Guest> searchByName(@Param("searchTerm") String searchTerm);

    // Find guests by nationality
    List<Guest> findByNationality(String nationality);

    // Find guests by city
    List<Guest> findByCity(String city);

    // Find guests by country
    List<Guest> findByCountry(String country);

    // Check if email exists
    boolean existsByEmail(String email);

    // Check if phone exists
    boolean existsByPhone(String phone);

    // Check if ID proof exists
    boolean existsByIdProofNumber(String idProofNumber);

    // Get recent guests
    @Query("SELECT g FROM Guest g ORDER BY g.createdAt DESC LIMIT 10")
    List<Guest> findRecentGuests();

    // Get guests with booking count
    @Query("SELECT g, COUNT(b) as bookingCount FROM Guest g LEFT JOIN Booking b ON g.id = b.guest.id GROUP BY g")
    List<Object[]> findGuestsWithBookingCount();

    // Get guests by booking status
    @Query("SELECT DISTINCT g FROM Guest g JOIN Booking b ON g.id = b.guest.id WHERE b.status = :status")
    List<Guest> findGuestsByBookingStatus(@Param("status") String status);

    // FIXED: Find guests who checked in today - using b.checkInDate directly
    @Query("SELECT DISTINCT g FROM Guest g JOIN Booking b ON g.id = b.guest.id WHERE b.status = 'CHECKED_IN' AND b.checkInDate = :today")
    List<Guest> findTodayCheckIns(@Param("today") LocalDate today);

    // FIXED: Find guests who will check out today
    @Query("SELECT DISTINCT g FROM Guest g JOIN Booking b ON g.id = b.guest.id WHERE b.status = 'CHECKED_IN' AND b.checkOutDate = :today")
    List<Guest> findTodayCheckOuts(@Param("today") LocalDate today);
}