package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "payments")
@Data
public class Payment extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "booking_id")
    private Booking booking;

    private String paymentNumber;

    private Double amount;

    private String paymentMethod; // CASH, CARD, BANK_TRANSFER, MOBILE_BANKING, ONLINE

    private String paymentStatus; // PENDING, COMPLETED, FAILED, REFUNDED

    private LocalDateTime paymentDate;

    private String transactionId;

    private String cardLastFour;

    private String bankName;

    private String chequeNumber;

    private String mobileBankingProvider; // bKash, Nagad, Rocket

    private String mobileAccountNo;

    private String reference;

    private String notes;

    private String receivedBy;

    private Long hotelId;
}