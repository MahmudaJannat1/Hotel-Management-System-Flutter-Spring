package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.StockTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface StockTransactionRepository extends JpaRepository<StockTransaction, Long> {

    List<StockTransaction> findByInventoryItemId(Long itemId);

    List<StockTransaction> findByTransactionType(String transactionType);

    List<StockTransaction> findByHotelId(Long hotelId);

    @Query("SELECT st FROM StockTransaction st WHERE st.transactionDate BETWEEN :startDate AND :endDate")
    List<StockTransaction> findByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT st FROM StockTransaction st WHERE st.inventoryItem.id = :itemId ORDER BY st.transactionDate DESC")
    List<StockTransaction> findRecentTransactionsByItem(@Param("itemId") Long itemId);

    @Query("SELECT SUM(st.quantity) FROM StockTransaction st WHERE st.inventoryItem.id = :itemId AND st.transactionType = 'CONSUMPTION' AND st.transactionDate BETWEEN :startDate AND :endDate")
    Integer getTotalConsumption(@Param("itemId") Long itemId, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}