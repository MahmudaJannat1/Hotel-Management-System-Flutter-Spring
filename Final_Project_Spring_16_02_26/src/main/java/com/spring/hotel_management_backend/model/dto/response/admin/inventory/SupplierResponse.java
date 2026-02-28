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
public class SupplierResponse {
    private Long id;
    private String name;
    private String contactPerson;
    private String email;
    private String phone;
    private String address;
    private String city;
    private String country;
    private String paymentTerms;
    private String taxId;
    private String website;
    private String notes;
    private Boolean isActive;
    private Long hotelId;
    private Integer totalPurchaseOrders;
    private Double totalPurchaseValue;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}