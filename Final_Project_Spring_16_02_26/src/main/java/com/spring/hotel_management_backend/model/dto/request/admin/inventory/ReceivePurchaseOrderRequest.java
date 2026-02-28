package com.spring.hotel_management_backend.model.dto.request.admin.inventory;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class ReceivePurchaseOrderRequest {

    private List<ReceivedItem> receivedItems;
    private String notes;

    @Data
    public static class ReceivedItem {
        private Long purchaseOrderItemId;
        private Integer receivedQuantity;
        private String batchNo;          // Optional: for tracking batches
        private LocalDate expiryDate;     // Optional: for perishable items
        private String condition;         // Optional: GOOD, DAMAGED, EXPIRED
        private String remarks;           // Optional: any additional notes
    }
}