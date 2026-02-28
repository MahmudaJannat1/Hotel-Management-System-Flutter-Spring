package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "stock_transactions")
@Data
public class StockTransaction extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "inventory_item_id")
    private Inventory inventoryItem;

    private String transactionType; // PURCHASE, CONSUMPTION, RETURN, ADJUSTMENT, TRANSFER

    private Integer quantity;
    private Integer changeAmount;

    private Double unitPrice;

    private Double totalPrice;

    private Integer previousQuantity;

    private Integer newQuantity;

    private String reference; // PO number, Booking ID, etc.

    private String reason;

    private String performedBy;

    private LocalDateTime transactionDate;

    private String notes;

    private Long hotelId;
}