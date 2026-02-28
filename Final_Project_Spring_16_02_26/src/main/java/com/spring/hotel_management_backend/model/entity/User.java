package com.spring.hotel_management_backend.model.entity;

import com.spring.hotel_management_backend.model.enums.RoleType;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "users")
@Data
public class User extends BaseEntity {

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    private String firstName;
    private String lastName;
    private String phoneNumber;

    @Enumerated(EnumType.STRING)
    private RoleType role;

    private Boolean isActive = true;

    private String profileImageUrl;

    @ManyToOne
    @JoinColumn(name = "hotel_id")
    private Hotel hotel;
}