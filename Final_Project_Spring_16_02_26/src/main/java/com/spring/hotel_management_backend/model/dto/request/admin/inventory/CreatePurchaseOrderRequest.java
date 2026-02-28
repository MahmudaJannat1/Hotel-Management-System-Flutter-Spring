package com.spring.hotel_management_backend.model.dto.request.admin.inventory;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class CreatePurchaseOrderRequest {
    private Long supplierId;
    private LocalDate expectedDeliveryDate;
    private Double taxAmount;
    private Double discountAmount;
    private String paymentTerms;
    private String notes;
    private Long hotelId;

    private List<PurchaseOrderItemRequest> items;

    @Data
    public static class PurchaseOrderItemRequest {
        private Long inventoryItemId;
        private Integer orderedQuantity;
        private Double unitPrice;
    }
}