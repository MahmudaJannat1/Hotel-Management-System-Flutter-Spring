package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Hotel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HotelRepository extends JpaRepository<Hotel, Long> {

    // Find by name (exact match)
    Optional<Hotel> findByName(String name);

    // Find by name containing (search)
    List<Hotel> findByNameContainingIgnoreCase(String name);

    // Find by city
    List<Hotel> findByCity(String city);

    // Find by country
    List<Hotel> findByCountry(String country);

    // Find by star rating
    List<Hotel> findByStarRating(Integer starRating);

    // Find hotels with rating greater than or equal
    List<Hotel> findByStarRatingGreaterThanEqual(Integer starRating);

    // Search hotels by name, city, or country
    @Query("SELECT h FROM Hotel h WHERE " +
            "LOWER(h.name) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(h.city) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(h.country) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    List<Hotel> searchHotels(@Param("searchTerm") String searchTerm);

    // Get hotels with most bookings
    @Query("SELECT h, COUNT(b) as bookingCount FROM Hotel h " +
            "LEFT JOIN Room r ON r.hotel = h " +
            "LEFT JOIN Booking b ON b.room = r " +
            "GROUP BY h ORDER BY bookingCount DESC")
    List<Object[]> findHotelsByBookingCount();

    // Get hotels with highest revenue
    @Query("SELECT h, SUM(b.totalAmount) as revenue FROM Hotel h " +
            "LEFT JOIN Room r ON r.hotel = h " +
            "LEFT JOIN Booking b ON b.room = r " +
            "WHERE b.status = 'CHECKED_OUT' " +
            "GROUP BY h ORDER BY revenue DESC")
    List<Object[]> findHotelsByRevenue();

    // Check if hotel exists by name and city
    boolean existsByNameAndCity(String name, String city);

    // Get all active hotels
    @Query("SELECT h FROM Hotel h WHERE h.isActive = true")
    List<Hotel> findAllActive();

    // Get hotel statistics
    @Query("SELECT " +
            "COUNT(h) as totalHotels, " +
            "AVG(h.starRating) as avgRating, " +
            "COUNT(DISTINCT h.city) as totalCities, " +
            "COUNT(DISTINCT h.country) as totalCountries " +
            "FROM Hotel h")
    List<Object[]> getHotelStatistics();

    // Find hotels by name pattern (for autocomplete)
    @Query("SELECT h.name FROM Hotel h WHERE LOWER(h.name) LIKE LOWER(CONCAT(:prefix, '%'))")
    List<String> findHotelNamesByPrefix(@Param("prefix") String prefix);
}