package com.spring.hotel_management_backend.model.dto.response.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {
    private Long id;
    private String bookingNumber;

    // Guest info
    private Long guestId;
    private String guestName;
    private String guestEmail;
    private String guestPhone;

    // Room info
    private Long roomId;
    private String roomNumber;
    private String roomTypeName;
    private Long hotelId;
    private String hotelName;

    // Booking details
    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private Integer numberOfNights;
    private Integer numberOfGuests;
    private String status;

    // Pricing
    private Double roomPrice;
    private Double totalAmount;
    private Double advancePayment;
    private Double dueAmount;
    private String paymentMethod;

    // Other
    private String specialRequests;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
}