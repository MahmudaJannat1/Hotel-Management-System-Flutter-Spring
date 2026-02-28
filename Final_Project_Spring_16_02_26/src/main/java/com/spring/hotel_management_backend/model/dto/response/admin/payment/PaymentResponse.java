package com.spring.hotel_management_backend.model.dto.response.admin.payment;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentResponse {
    private Long id;
    private String paymentNumber;

    // Booking info
    private Long bookingId;
    private String bookingNumber;
    private String guestName;
    private String roomNumber;

    private Double amount;
    private String paymentMethod;
    private String paymentStatus;
    private LocalDateTime paymentDate;
    private String transactionId;
    private String cardLastFour;
    private String bankName;
    private String chequeNumber;
    private String mobileBankingProvider;
    private String mobileAccountNo;
    private String reference;
    private String notes;
    private String receivedBy;
}