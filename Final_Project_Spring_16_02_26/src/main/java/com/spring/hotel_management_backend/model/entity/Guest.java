package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "guests")
@Data
public class Guest extends BaseEntity {

    @Column(nullable = false)
    private String firstName;

    private String lastName;

    @Column(unique = true)
    private String email;

    private String phone;

    private String address;

    private String city;

    private String country;

    private String idProofType; // PASSPORT, DRIVING_LICENSE, NATIONAL_ID

    private String idProofNumber;

    private String nationality;

    private LocalDate dateOfBirth;

    private String gender;
}