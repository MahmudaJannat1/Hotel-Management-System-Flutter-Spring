package com.spring.hotel_management_backend.model.dto.response.admin.inventory;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StockTransactionResponse {
    private Long id;

    // Item info
    private Long inventoryItemId;
    private String itemName;
    private String itemCode;

    // Transaction details
    private String transactionType;
    private Integer quantity;
    private Double unitPrice;
    private Double totalPrice;

    // Stock changes
    private Integer previousQuantity;
    private Integer newQuantity;
    private Integer changeAmount;

    private String reference;
    private String reason;
    private String performedBy;
    private LocalDateTime transactionDate;
    private String notes;

    private Long hotelId;
}