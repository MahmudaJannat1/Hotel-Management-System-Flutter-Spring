package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "hotels")
@Data
public class Hotel extends BaseEntity {

    @Column(unique = true, nullable = false)
    private String name;

    private String address;
    private String city;
    private String country;
    private String phone;
    private String email;
    private String website;
    private Integer starRating;

    @Column(length = 1000)
    private String description;

    private String logoUrl;
    private String checkInTime;
    private String checkOutTime;

    @Column(name = "is_active")
    private Boolean isActive = true;
}