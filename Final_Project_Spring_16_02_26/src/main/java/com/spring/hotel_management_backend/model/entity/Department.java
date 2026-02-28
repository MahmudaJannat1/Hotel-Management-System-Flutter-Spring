package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "departments")
@Data
public class Department extends BaseEntity {

    @Column(unique = true, nullable = false)
    private String name;

    private String description;

    private String headOfDepartment;

    private Long headEmployeeId;

    private String location;

    private String contactNumber;

    private String email;

    private Integer totalEmployees;

    private Boolean isActive = true;

    private Long hotelId;
}