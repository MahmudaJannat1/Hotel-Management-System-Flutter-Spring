package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "inventory")
@Data
public class Inventory extends BaseEntity {

    @Column(nullable = false)
    private String itemName;

    private String itemCode; // SKU

    private String category; // FOOD, BEVERAGE, CLEANING, LINEN, AMENITIES, STATIONERY, etc.

    private String subCategory;

    private String description;

    private Integer quantity;

    private String unit; // PIECES, KG, LITRE, BOTTLE, PACK, BOX

    private Double unitPrice;

    private Integer reorderLevel;

    private Integer maximumLevel;

    private String location; // STORAGE location, rack number

    private String supplier; // Default supplier

    private Long supplierId; // Reference to Supplier entity

    private String brand;

    private String specifications;

    private String imageUrl;

    private String barcode;

    @Column(name = "is_active")
    private Boolean isActive = true;

    private LocalDate expiryDate;

    private String batchNo;

    private String notes;

    private Long hotelId;
}