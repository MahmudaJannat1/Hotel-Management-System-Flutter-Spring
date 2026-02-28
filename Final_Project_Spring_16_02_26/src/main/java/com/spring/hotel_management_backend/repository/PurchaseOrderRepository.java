package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Long> {

    Optional<PurchaseOrder> findByPoNumber(String poNumber);

    List<PurchaseOrder> findBySupplierId(Long supplierId);

    List<PurchaseOrder> findByHotelId(Long hotelId);

    List<PurchaseOrder> findByStatus(String status);

    List<PurchaseOrder> findByPaymentStatus(String paymentStatus);

    @Query("SELECT po FROM PurchaseOrder po WHERE po.orderDate BETWEEN :startDate AND :endDate")
    List<PurchaseOrder> findByDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT po FROM PurchaseOrder po WHERE po.expectedDeliveryDate <= :date AND po.status NOT IN ('COMPLETED', 'CANCELLED')")
    List<PurchaseOrder> findPendingDeliveries(@Param("date") LocalDate date);

    List<PurchaseOrder> findByStatusIn(List<String> statuses);

    @Query("SELECT SUM(po.totalAmount) FROM PurchaseOrder po WHERE po.hotelId = :hotelId AND po.status = 'COMPLETED' AND po.orderDate BETWEEN :startDate AND :endDate")
    Double getTotalPurchases(@Param("hotelId") Long hotelId, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
}