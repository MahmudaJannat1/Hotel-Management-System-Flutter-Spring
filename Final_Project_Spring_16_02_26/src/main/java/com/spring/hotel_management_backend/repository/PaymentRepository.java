package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {

    List<Payment> findByBookingId(Long bookingId);

    List<Payment> findByPaymentStatus(String status);

    @Query("SELECT p FROM Payment p WHERE p.paymentDate BETWEEN :startDate AND :endDate")
    List<Payment> findByDateRange(@Param("startDate") LocalDateTime startDate,
                                  @Param("endDate") LocalDateTime endDate);

    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.paymentStatus = 'COMPLETED' AND p.paymentDate BETWEEN :startDate AND :endDate")
    Double getTotalRevenue(@Param("startDate") LocalDateTime startDate,
                           @Param("endDate") LocalDateTime endDate);

    @Query("SELECT p.paymentMethod, SUM(p.amount) FROM Payment p WHERE p.paymentStatus = 'COMPLETED' GROUP BY p.paymentMethod")
    List<Object[]> getRevenueByPaymentMethod();

    List<Payment> findByHotelId(Long hotelId);
}