package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Booking;
import com.spring.hotel_management_backend.model.enums.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {

    List<Booking> findByGuestId(Long guestId);

    List<Booking> findByRoomId(Long roomId);

    List<Booking> findByStatus(BookingStatus status);

    @Query("SELECT b FROM Booking b WHERE b.room.hotel.id = :hotelId")
    List<Booking> findByHotelId(@Param("hotelId") Long hotelId);

    @Query("SELECT b FROM Booking b WHERE b.room.id = :roomId AND " +
            "(b.checkInDate <= :endDate AND b.checkOutDate >= :startDate) AND " +
            "b.status NOT IN ('CANCELLED', 'CHECKED_OUT')")
    List<Booking> findConflictingBookings(
            @Param("roomId") Long roomId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT b FROM Booking b WHERE b.checkInDate = :date")
    List<Booking> findTodaysCheckIns(@Param("date") LocalDate date);

    @Query("SELECT b FROM Booking b WHERE b.checkOutDate = :date")
    List<Booking> findTodaysCheckOuts(@Param("date") LocalDate date);

    @Query("SELECT COUNT(b) FROM Booking b WHERE b.room.hotel.id = :hotelId AND b.status = 'CONFIRMED'")
    Long countActiveBookings(@Param("hotelId") Long hotelId);

    @Query("SELECT COALESCE(SUM(b.totalAmount), 0) FROM Booking b WHERE b.room.hotel.id = :hotelId AND b.status IN ('CHECKED_IN', 'CHECKED_OUT')")
    Double getTotalRevenue(@Param("hotelId") Long hotelId);
}