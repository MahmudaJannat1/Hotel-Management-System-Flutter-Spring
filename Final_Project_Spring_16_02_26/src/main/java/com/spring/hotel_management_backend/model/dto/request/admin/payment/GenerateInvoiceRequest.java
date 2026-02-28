package com.spring.hotel_management_backend.model.dto.request.admin.payment;

import lombok.Data;
import java.time.LocalDate;

@Data
public class GenerateInvoiceRequest {
    private Long bookingId;
    private LocalDate dueDate;
    private Double roomCharges;
    private Double foodCharges;
    private Double serviceCharges;
    private Double taxRate;
    private Double discountAmount;
    private String notes;
    private String termsAndConditions;
    private String generatedBy;
}