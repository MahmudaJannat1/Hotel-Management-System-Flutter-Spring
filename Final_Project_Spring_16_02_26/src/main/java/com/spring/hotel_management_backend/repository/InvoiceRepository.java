package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    Optional<Invoice> findByInvoiceNumber(String invoiceNumber);

    Optional<Invoice> findByBookingId(Long bookingId);

    List<Invoice> findByStatus(String status);

    List<Invoice> findByPaymentStatus(String paymentStatus);

    @Query("SELECT i FROM Invoice i WHERE i.invoiceDate BETWEEN :startDate AND :endDate")
    List<Invoice> findByDateRange(@Param("startDate") LocalDate startDate,
                                  @Param("endDate") LocalDate endDate);

    @Query("SELECT SUM(i.totalAmount) FROM Invoice i WHERE i.status = 'PAID' AND i.invoiceDate BETWEEN :startDate AND :endDate")
    Double getTotalInvoicedAmount(@Param("startDate") LocalDate startDate,
                                  @Param("endDate") LocalDate endDate);

    @Query("SELECT SUM(i.dueAmount) FROM Invoice i WHERE i.status != 'PAID' AND i.status != 'CANCELLED'")
    Double getTotalOutstandingAmount();
}