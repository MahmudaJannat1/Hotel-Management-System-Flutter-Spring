package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.payment.*;
import com.spring.hotel_management_backend.model.dto.response.admin.payment.*;
import java.time.LocalDate;
import java.util.List;

public interface PaymentService {

    // Payment
    PaymentResponse processPayment(ProcessPaymentRequest request);
    List<PaymentResponse> getPaymentsByBooking(Long bookingId);
    List<PaymentResponse> getPaymentsByDateRange(LocalDate startDate, LocalDate endDate);
    PaymentResponse getPaymentById(Long id);
    PaymentResponse refundPayment(Long id, String reason);
    List<PaymentResponse> getAllPayments(Long hotelId);


    // Invoice
    InvoiceResponse generateInvoice(GenerateInvoiceRequest request);
    InvoiceResponse getInvoiceByBooking(Long bookingId);
    InvoiceResponse getInvoiceById(Long id);
    InvoiceResponse updateInvoiceStatus(Long id, String status);
    List<InvoiceResponse> getInvoicesByStatus(String status);

    // Reports
    Double getTotalRevenue(LocalDate startDate, LocalDate endDate);
    Double getOutstandingAmount();
}