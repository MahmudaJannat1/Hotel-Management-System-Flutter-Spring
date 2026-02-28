package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalTime;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "shifts")
@Data
public class Shift extends BaseEntity {

    private String name; // MORNING, EVENING, NIGHT, GENERAL

    private LocalTime startTime;

    private LocalTime endTime;

    private Double totalHours;

    private String description;

    private Double overtimeRate; // Multiplier for overtime pay

    private Boolean isActive = true;

    private Long hotelId;
}