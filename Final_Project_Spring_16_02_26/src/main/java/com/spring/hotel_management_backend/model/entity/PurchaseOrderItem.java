package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "purchase_order_items")
@Data
public class PurchaseOrderItem extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "purchase_order_id")
    private PurchaseOrder purchaseOrder;

    @ManyToOne
    @JoinColumn(name = "inventory_item_id")
    private Inventory inventoryItem;

    private Integer orderedQuantity;

    private Integer receivedQuantity;

    private Double unitPrice;

    private Double totalPrice;

    private String unit; // PIECES, KG, LITRE, etc.

    private String status; // PENDING, PARTIALLY_RECEIVED, RECEIVED
}