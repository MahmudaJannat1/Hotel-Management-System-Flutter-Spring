package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "purchase_orders")
@Data
public class PurchaseOrder extends BaseEntity {

    @Column(unique = true, nullable = false)
    private String poNumber; // Purchase Order Number

    @ManyToOne
    @JoinColumn(name = "supplier_id")
    private Supplier supplier;

    private LocalDate orderDate;

    private LocalDate expectedDeliveryDate;

    private LocalDate receivedDate;

    private String status; // PENDING, APPROVED, SENT, PARTIALLY_RECEIVED, COMPLETED, CANCELLED

    private Double subtotal;

    private Double taxAmount;

    private Double discountAmount;

    private Double totalAmount;

    private String paymentStatus; // PENDING, PAID, PARTIALLY_PAID

    private String paymentTerms;

    private String notes;

    private String createdBy;

    private String approvedBy;

    private LocalDate approvedDate;

    @OneToMany(mappedBy = "purchaseOrder", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private List<PurchaseOrderItem> items = new ArrayList<>();

    private Long hotelId;
}