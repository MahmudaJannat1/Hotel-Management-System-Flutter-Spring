package com.spring.hotel_management_backend.model.dto.request.admin.inventory;

import lombok.Data;

@Data
public class CreateSupplierRequest {
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
    private Long hotelId;
}