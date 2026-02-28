package com.spring.hotel_management_backend.model.dto.request.admin.inventory;

import lombok.Data;

@Data
public class StockAdjustRequest {
    private Integer newQuantity;
    private String reason;
    private String notes;
    private String reference;
}