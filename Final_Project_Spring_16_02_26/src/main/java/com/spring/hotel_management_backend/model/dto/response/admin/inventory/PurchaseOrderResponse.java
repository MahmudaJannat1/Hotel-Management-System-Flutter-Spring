package com.spring.hotel_management_backend.model.dto.response.admin.inventory;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseOrderResponse {
    private Long id;
    private String poNumber;

    // Supplier info
    private Long supplierId;
    private String supplierName;
    private String supplierContact;
    private String supplierPhone;

    // Dates
    private LocalDate orderDate;
    private LocalDate expectedDeliveryDate;
    private LocalDate receivedDate;

    // Status
    private String status;
    private String paymentStatus;

    // Financial
    private Double subtotal;
    private Double taxAmount;
    private Double discountAmount;
    private Double totalAmount;
    private String paymentTerms;

    private String notes;
    private String createdBy;
    private String approvedBy;
    private LocalDate approvedDate;

    private List<PurchaseOrderItemResponse> items;

    private Long hotelId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PurchaseOrderItemResponse {
        private Long id;
        private Long inventoryItemId;
        private String itemName;
        private String itemCode;
        private String unit;
        private Integer orderedQuantity;
        private Integer receivedQuantity;
        private Integer pendingQuantity;
        private Double unitPrice;
        private Double totalPrice;
        private String status;
    }
}