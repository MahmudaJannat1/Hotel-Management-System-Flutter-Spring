package com.spring.hotel_management_backend.model.dto.response.admin.payment;

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
public class InvoiceResponse {
    private Long id;
    private String invoiceNumber;

    // Booking info
    private Long bookingId;
    private String bookingNumber;

    // Guest info
    private String guestName;
    private String guestEmail;
    private String guestPhone;

    // Room info
    private String roomNumber;
    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private Integer numberOfNights;

    // Dates
    private LocalDate invoiceDate;
    private LocalDate dueDate;

    // Amounts
    private Double roomCharges;
    private Double foodCharges;
    private Double serviceCharges;
    private Double taxAmount;
    private Double discountAmount;
    private Double totalAmount;
    private Double paidAmount;
    private Double dueAmount;

    // Status
    private String status;
    private String paymentStatus;

    private String pdfUrl;
    private String notes;
    private LocalDateTime createdAt;
}