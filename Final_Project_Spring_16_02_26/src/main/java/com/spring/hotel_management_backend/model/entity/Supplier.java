package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "suppliers")
@Data
public class Supplier extends BaseEntity {

    @Column(nullable = false)
    private String name;

    private String contactPerson;

    @Column(unique = true)
    private String email;

    private String phone;

    private String address;

    private String city;

    private String country;

    private String paymentTerms; // NET30, NET60, etc.

    private String taxId;

    private String website;

    private String notes;

    private Boolean isActive = true;

    private Long hotelId; // Supplier belongs to a hotel
}