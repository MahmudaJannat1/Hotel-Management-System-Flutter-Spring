package com.spring.hotel_management_backend.model.entity;

import com.spring.hotel_management_backend.model.enums.BookingStatus;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "bookings")
@Data
public class Booking extends BaseEntity {

    @Column(unique = true, nullable = false)
    private String bookingNumber;

    @ManyToOne
    @JoinColumn(name = "guest_id", nullable = false)
    private Guest guest;

    @ManyToOne
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @Column(nullable = false)
    private LocalDate checkInDate;

    @Column(nullable = false)
    private LocalDate checkOutDate;

    private Integer numberOfGuests;

    @Enumerated(EnumType.STRING)
    private BookingStatus status;

    private Double totalAmount;

    private Double advancePayment;

    private Double dueAmount;

    private String paymentMethod;

    @Column(length = 1000)
    private String specialRequests;

    private String createdBy;
}