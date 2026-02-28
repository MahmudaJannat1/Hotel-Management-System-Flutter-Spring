package com.spring.hotel_management_backend.model.dto.request.admin.inventory;

import lombok.Data;

import java.time.LocalDate;

@Data
public class CreateInventoryItemRequest {
    private String itemName;
    private String itemCode;
    private String category;
    private String subCategory;
    private String description;
    private Integer quantity;
    private String unit;
    private Double unitPrice;
    private Integer reorderLevel;
    private Integer maximumLevel;
    private String location;
    private String supplier;
    private Long supplierId;
    private String brand;
    private String specifications;
    private String imageUrl;
    private String barcode;
    private LocalDate expiryDate;
    private String batchNo;
    private String notes;
    private Long hotelId;
}