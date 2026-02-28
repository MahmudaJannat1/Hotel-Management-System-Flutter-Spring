package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "permissions")
@Data
public class Permission extends BaseEntity {

    @Column(unique = true, nullable = false)
    private String name;

    private String module;
    private String action; // CREATE, READ, UPDATE, DELETE
    private String description;
}