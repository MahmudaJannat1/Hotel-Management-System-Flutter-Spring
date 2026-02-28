package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Inventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InventoryRepository extends JpaRepository<Inventory, Long> {

    // Find inventory by hotel ID
    List<Inventory> findByHotelId(Long hotelId);

    // Find inventory by category
    List<Inventory> findByCategory(String category);

    // Find low stock items (quantity <= reorder level)
    @Query("SELECT i FROM Inventory i WHERE i.quantity <= i.reorderLevel")
    List<Inventory> findLowStockItems();

    // Find inventory by name (search)
    List<Inventory> findByItemNameContainingIgnoreCase(String itemName);

    // Find inventory by hotel and category
    List<Inventory> findByHotelIdAndCategory(Long hotelId, String category);

    // Get total inventory value by hotel
    @Query("SELECT SUM(i.quantity * i.unitPrice) FROM Inventory i WHERE i.hotelId = :hotelId")
    Double getTotalInventoryValue(@Param("hotelId") Long hotelId);

    // Find expiring items (if you have expiry date)
    // List<Inventory> findByExpiryDateBefore(LocalDate date);
}