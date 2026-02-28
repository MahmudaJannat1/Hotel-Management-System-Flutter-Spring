package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.payment.*;
import com.spring.hotel_management_backend.model.dto.response.admin.payment.*;
import com.spring.hotel_management_backend.service.admin.PaymentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/admin/payments")
@RequiredArgsConstructor
@Tag(name = "Payment & Invoice", description = "Admin payment and invoice management APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class PaymentController {

    private final PaymentService paymentService;

    // ========== Payment Endpoints ==========

    @GetMapping
    @Operation(summary = "Get all payments")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PaymentResponse>> getAllPayments(@RequestParam Long hotelId) {
        return ResponseEntity.ok(paymentService.getAllPayments(hotelId));
    }


    @PostMapping("/process")
    @Operation(summary = "Process payment")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PaymentResponse> processPayment(@RequestBody ProcessPaymentRequest request) {
        return new ResponseEntity<>(paymentService.processPayment(request), HttpStatus.CREATED);
    }

    @GetMapping("/booking/{bookingId}")
    @Operation(summary = "Get payments by booking")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PaymentResponse>> getPaymentsByBooking(@PathVariable Long bookingId) {
        return ResponseEntity.ok(paymentService.getPaymentsByBooking(bookingId));
    }

    @GetMapping("/date-range")
    @Operation(summary = "Get payments by date range")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PaymentResponse>> getPaymentsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(paymentService.getPaymentsByDateRange(startDate, endDate));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get payment by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PaymentResponse> getPaymentById(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.getPaymentById(id));
    }

    @PostMapping("/{id}/refund")
    @Operation(summary = "Refund payment")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PaymentResponse> refundPayment(
            @PathVariable Long id,
            @RequestParam String reason) {
        return ResponseEntity.ok(paymentService.refundPayment(id, reason));
    }

    // ========== Invoice Endpoints ==========

    @PostMapping("/invoices/generate")
    @Operation(summary = "Generate invoice")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InvoiceResponse> generateInvoice(@RequestBody GenerateInvoiceRequest request) {
        return new ResponseEntity<>(paymentService.generateInvoice(request), HttpStatus.CREATED);
    }

    @GetMapping("/invoices/booking/{bookingId}")
    @Operation(summary = "Get invoice by booking")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InvoiceResponse> getInvoiceByBooking(@PathVariable Long bookingId) {
        return ResponseEntity.ok(paymentService.getInvoiceByBooking(bookingId));
    }

    @GetMapping("/invoices/{id}")
    @Operation(summary = "Get invoice by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InvoiceResponse> getInvoiceById(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.getInvoiceById(id));
    }

    @PatchMapping("/invoices/{id}/status")
    @Operation(summary = "Update invoice status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<InvoiceResponse> updateInvoiceStatus(
            @PathVariable Long id,
            @RequestParam String status) {
        return ResponseEntity.ok(paymentService.updateInvoiceStatus(id, status));
    }

    @GetMapping("/invoices/status/{status}")
    @Operation(summary = "Get invoices by status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<InvoiceResponse>> getInvoicesByStatus(@PathVariable String status) {
        return ResponseEntity.ok(paymentService.getInvoicesByStatus(status));
    }

    // ========== Report Endpoints ==========

    @GetMapping("/reports/revenue")
    @Operation(summary = "Get total revenue")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Double> getTotalRevenue(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(paymentService.getTotalRevenue(startDate, endDate));
    }

    @GetMapping("/reports/outstanding")
    @Operation(summary = "Get total outstanding amount")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Double> getOutstandingAmount() {
        return ResponseEntity.ok(paymentService.getOutstandingAmount());
    }
}