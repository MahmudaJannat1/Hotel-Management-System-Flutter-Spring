package com.spring.hotel_management_backend.model.dto.request.admin.payment;

import lombok.Data;

@Data
public class ProcessPaymentRequest {
    private Long bookingId;
    private Double amount;
    private String paymentMethod; // CASH, CARD, BANK_TRANSFER, MOBILE_BANKING, ONLINE
    private String transactionId;
    private String cardLastFour;
    private String bankName;
    private String chequeNumber;
    private String mobileBankingProvider; // bKash, Nagad, Rocket
    private String mobileAccountNo;
    private String reference;
    private String notes;
    private String receivedBy;
}