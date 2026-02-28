package com.spring.hotel_management_backend.model.dto.request.admin;

import lombok.Data;

import java.time.LocalDate;

@Data
public class CreateBookingRequest {
    private Long guestId;
    private Long roomId;
    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private Integer numberOfGuests;
    private String specialRequests;
    private String paymentMethod; // CASH, CARD, ONLINE
    private Double advancePayment;
}