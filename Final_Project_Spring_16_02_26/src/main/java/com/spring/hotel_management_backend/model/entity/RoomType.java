package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "room_types")
@Data
public class RoomType extends BaseEntity {

    @Column(unique = true, nullable = false)
    private String name;

    private String description;

    @Column
    private BigDecimal basePrice;

    private Integer maxOccupancy;

    private String amenities; // JSON string of default amenities

    private String images; // JSON string of sample images

    private Boolean isActive = true;

    @ManyToOne
    @JoinColumn(name = "hotel_id")
    private Hotel hotel;
}