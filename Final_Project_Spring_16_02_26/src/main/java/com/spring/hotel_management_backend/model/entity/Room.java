package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "rooms")
@Data
public class Room extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "hotel_id")
    private Hotel hotel;

    @Column(nullable = false)
    private String roomNumber;

    @ManyToOne
    @JoinColumn(name = "room_type_id")
    private RoomType roomType;

    private String floor;
    private String status; // AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED

    @Column
    private BigDecimal basePrice;

    @Column(length = 1000)
    private String description;

    private Integer maxOccupancy;
    private String amenities; // JSON string
    private String images; // JSON string



}