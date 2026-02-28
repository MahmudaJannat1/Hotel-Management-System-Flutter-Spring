package com.spring.hotel_management_backend.model.dto.response.admin.inventory;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InventoryItemResponse {
    private Long id;
    private String itemName;
    private String itemCode;
    private String category;
    private String subCategory;
    private String description;
    private Integer quantity;
    private String unit;
    private Double unitPrice;
    private Double totalValue;
    private Integer reorderLevel;
    private Integer maximumLevel;
    private String location;
    private String supplier;
    private Long supplierId;
    private String supplierName;
    private String brand;
    private String specifications;
    private String imageUrl;
    private String barcode;
    private Boolean isActive;
    private LocalDate expiryDate;
    private String batchNo;
    private String notes;
    private Long hotelId;
    private String status; // NORMAL, LOW_STOCK, OUT_OF_STOCK, EXPIRING_SOON
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}