package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDate;
import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "invoices")
@Data
public class Invoice extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "booking_id")
    private Booking booking;

    private String invoiceNumber;

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

    // Tax
    private Double taxRate;

    private String taxDescription;

    // Status
    private String status; // DRAFT, SENT, PAID, PARTIALLY_PAID, OVERDUE, CANCELLED

    private String paymentStatus;

    // Guest info snapshot (in case guest changes later)
    private String guestName;

    private String guestEmail;

    private String guestPhone;

    private String guestAddress;

    // Booking info snapshot
    private String roomNumber;

    private LocalDate checkInDate;

    private LocalDate checkOutDate;

    private Integer numberOfNights;

    private Integer numberOfGuests;

    // PDF
    private String pdfUrl;

    private String notes;

    private String termsAndConditions;

    private String generatedBy;

    private String sentBy;

    private LocalDateTime sentAt;

    private Long hotelId;
}