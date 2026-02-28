package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.payment.*;
import com.spring.hotel_management_backend.model.dto.response.admin.payment.*;
import com.spring.hotel_management_backend.model.entity.*;
import com.spring.hotel_management_backend.repository.*;
import com.spring.hotel_management_backend.service.admin.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private final PaymentRepository paymentRepository;
    private final InvoiceRepository invoiceRepository;
    private final BookingRepository bookingRepository;
    private final GuestRepository guestRepository;

    private String generatePaymentNumber() {
        return "PAY" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
    }

    private String generateInvoiceNumber() {
        return "INV" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
    }

    @Override
    @Transactional
    public PaymentResponse processPayment(ProcessPaymentRequest request) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        Payment payment = new Payment();
        payment.setPaymentNumber(generatePaymentNumber());
        payment.setBooking(booking);
        payment.setAmount(request.getAmount());
        payment.setPaymentMethod(request.getPaymentMethod());
        payment.setPaymentStatus("COMPLETED");
        payment.setPaymentDate(LocalDateTime.now());
        payment.setTransactionId(request.getTransactionId());
        payment.setCardLastFour(request.getCardLastFour());
        payment.setBankName(request.getBankName());
        payment.setChequeNumber(request.getChequeNumber());
        payment.setMobileBankingProvider(request.getMobileBankingProvider());
        payment.setMobileAccountNo(request.getMobileAccountNo());
        payment.setReference(request.getReference());
        payment.setNotes(request.getNotes());
        payment.setReceivedBy(request.getReceivedBy());
        payment.setHotelId(booking.getRoom().getHotel().getId());

        Payment savedPayment = paymentRepository.save(payment);

        // Update invoice if exists
        invoiceRepository.findByBookingId(booking.getId()).ifPresent(invoice -> {
            double totalPaid = paymentRepository.findByBookingId(booking.getId())
                    .stream()
                    .filter(p -> "COMPLETED".equals(p.getPaymentStatus()))
                    .mapToDouble(Payment::getAmount)
                    .sum() + request.getAmount();

            invoice.setPaidAmount(totalPaid);
            invoice.setDueAmount(invoice.getTotalAmount() - totalPaid);

            if (invoice.getDueAmount() <= 0) {
                invoice.setPaymentStatus("PAID");
                invoice.setStatus("PAID");
            } else {
                invoice.setPaymentStatus("PARTIALLY_PAID");
            }

            invoiceRepository.save(invoice);
        });

        return mapToPaymentResponse(savedPayment);
    }

    @Override
    public List<PaymentResponse> getAllPayments(Long hotelId) {
        List<Payment> payments;
        if (hotelId != null) {
            payments = paymentRepository.findByHotelId(hotelId);
        } else {
            payments = paymentRepository.findAll();
        }
        return payments.stream()
                .map(this::mapToPaymentResponse)
                .collect(Collectors.toList());
    }
    @Override
    public List<PaymentResponse> getPaymentsByBooking(Long bookingId) {
        return paymentRepository.findByBookingId(bookingId)
                .stream()
                .map(this::mapToPaymentResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PaymentResponse> getPaymentsByDateRange(LocalDate startDate, LocalDate endDate) {
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        return paymentRepository.findByDateRange(startDateTime, endDateTime)
                .stream()
                .map(this::mapToPaymentResponse)
                .collect(Collectors.toList());
    }

    @Override
    public PaymentResponse getPaymentById(Long id) {
        Payment payment = paymentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        return mapToPaymentResponse(payment);
    }

    @Override
    @Transactional
    public PaymentResponse refundPayment(Long id, String reason) {
        Payment payment = paymentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Payment not found"));

        payment.setPaymentStatus("REFUNDED");
        payment.setNotes(payment.getNotes() + " [REFUNDED: " + reason + "]");

        Payment refundedPayment = paymentRepository.save(payment);

        // Update invoice
        invoiceRepository.findByBookingId(payment.getBooking().getId()).ifPresent(invoice -> {
            double totalPaid = paymentRepository.findByBookingId(payment.getBooking().getId())
                    .stream()
                    .filter(p -> "COMPLETED".equals(p.getPaymentStatus()))
                    .mapToDouble(Payment::getAmount)
                    .sum() - payment.getAmount();

            invoice.setPaidAmount(totalPaid);
            invoice.setDueAmount(invoice.getTotalAmount() - totalPaid);
            invoice.setPaymentStatus("PARTIALLY_PAID");

            invoiceRepository.save(invoice);
        });

        return mapToPaymentResponse(refundedPayment);
    }

    @Override
    @Transactional
    public InvoiceResponse generateInvoice(GenerateInvoiceRequest request) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        // Check if invoice already exists
        if (invoiceRepository.findByBookingId(booking.getId()).isPresent()) {
            throw new RuntimeException("Invoice already exists for this booking");
        }

        Guest guest = booking.getGuest();

        double roomCharges = request.getRoomCharges() != null ? request.getRoomCharges() :
                booking.getTotalAmount() - (request.getFoodCharges() != null ? request.getFoodCharges() : 0);

        double subtotal = roomCharges +
                (request.getFoodCharges() != null ? request.getFoodCharges() : 0) +
                (request.getServiceCharges() != null ? request.getServiceCharges() : 0);

        double taxAmount = request.getTaxRate() != null ?
                subtotal * request.getTaxRate() / 100 : 0;

        double total = subtotal + taxAmount -
                (request.getDiscountAmount() != null ? request.getDiscountAmount() : 0);

        long nights = booking.getCheckOutDate().toEpochDay() - booking.getCheckInDate().toEpochDay();

        Invoice invoice = new Invoice();
        invoice.setInvoiceNumber(generateInvoiceNumber());
        invoice.setBooking(booking);
        invoice.setInvoiceDate(LocalDate.now());
        invoice.setDueDate(request.getDueDate() != null ? request.getDueDate() : LocalDate.now().plusDays(7));

        // Amounts
        invoice.setRoomCharges(roomCharges);
        invoice.setFoodCharges(request.getFoodCharges());
        invoice.setServiceCharges(request.getServiceCharges());
        invoice.setTaxAmount(taxAmount);
        invoice.setDiscountAmount(request.getDiscountAmount());
        invoice.setTotalAmount(total);
        invoice.setPaidAmount(0.0);
        invoice.setDueAmount(total);

        // Tax
        invoice.setTaxRate(request.getTaxRate());
        invoice.setTaxDescription("VAT " + request.getTaxRate() + "%");

        // Status
        invoice.setStatus("SENT");
        invoice.setPaymentStatus("UNPAID");

        // Guest info snapshot
        invoice.setGuestName(guest.getFirstName() + " " + guest.getLastName());
        invoice.setGuestEmail(guest.getEmail());
        invoice.setGuestPhone(guest.getPhone());
        invoice.setGuestAddress(guest.getAddress());

        // Booking info snapshot
        invoice.setRoomNumber(booking.getRoom().getRoomNumber());
        invoice.setCheckInDate(booking.getCheckInDate());
        invoice.setCheckOutDate(booking.getCheckOutDate());
        invoice.setNumberOfNights((int) nights);
        invoice.setNumberOfGuests(booking.getNumberOfGuests());

        invoice.setNotes(request.getNotes());
        invoice.setTermsAndConditions(request.getTermsAndConditions());
        invoice.setGeneratedBy(request.getGeneratedBy());
        invoice.setHotelId(booking.getRoom().getHotel().getId());

        Invoice savedInvoice = invoiceRepository.save(invoice);
        return mapToInvoiceResponse(savedInvoice);
    }

    @Override
    public InvoiceResponse getInvoiceByBooking(Long bookingId) {
        Invoice invoice = invoiceRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new RuntimeException("Invoice not found for booking: " + bookingId));
        return mapToInvoiceResponse(invoice);
    }

    @Override
    public InvoiceResponse getInvoiceById(Long id) {
        Invoice invoice = invoiceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Invoice not found"));
        return mapToInvoiceResponse(invoice);
    }

    @Override
    @Transactional
    public InvoiceResponse updateInvoiceStatus(Long id, String status) {
        Invoice invoice = invoiceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Invoice not found"));

        invoice.setStatus(status);

        Invoice updatedInvoice = invoiceRepository.save(invoice);
        return mapToInvoiceResponse(updatedInvoice);
    }

    @Override
    public List<InvoiceResponse> getInvoicesByStatus(String status) {
        return invoiceRepository.findByStatus(status)
                .stream()
                .map(this::mapToInvoiceResponse)
                .collect(Collectors.toList());
    }

    @Override
    public Double getTotalRevenue(LocalDate startDate, LocalDate endDate) {
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        Double revenue = paymentRepository.getTotalRevenue(startDateTime, endDateTime);
        return revenue != null ? revenue : 0.0;
    }

    @Override
    public Double getOutstandingAmount() {
        Double outstanding = invoiceRepository.getTotalOutstandingAmount();
        return outstanding != null ? outstanding : 0.0;
    }

    private PaymentResponse mapToPaymentResponse(Payment payment) {
        Booking booking = payment.getBooking();
        Guest guest = booking.getGuest();

        return PaymentResponse.builder()
                .id(payment.getId())
                .paymentNumber(payment.getPaymentNumber())
                .bookingId(booking.getId())
                .bookingNumber(booking.getBookingNumber())
                .guestName(guest.getFirstName() + " " + guest.getLastName())
                .roomNumber(booking.getRoom().getRoomNumber())
                .amount(payment.getAmount())
                .paymentMethod(payment.getPaymentMethod())
                .paymentStatus(payment.getPaymentStatus())
                .paymentDate(payment.getPaymentDate())
                .transactionId(payment.getTransactionId())
                .cardLastFour(payment.getCardLastFour())
                .bankName(payment.getBankName())
                .chequeNumber(payment.getChequeNumber())
                .mobileBankingProvider(payment.getMobileBankingProvider())
                .mobileAccountNo(payment.getMobileAccountNo())
                .reference(payment.getReference())
                .notes(payment.getNotes())
                .receivedBy(payment.getReceivedBy())
                .build();
    }

    private InvoiceResponse mapToInvoiceResponse(Invoice invoice) {
        return InvoiceResponse.builder()
                .id(invoice.getId())
                .invoiceNumber(invoice.getInvoiceNumber())
                .bookingId(invoice.getBooking().getId())
                .bookingNumber(invoice.getBooking().getBookingNumber())
                .guestName(invoice.getGuestName())
                .guestEmail(invoice.getGuestEmail())
                .guestPhone(invoice.getGuestPhone())
                .roomNumber(invoice.getRoomNumber())
                .checkInDate(invoice.getCheckInDate())
                .checkOutDate(invoice.getCheckOutDate())
                .numberOfNights(invoice.getNumberOfNights())
                .invoiceDate(invoice.getInvoiceDate())
                .dueDate(invoice.getDueDate())
                .roomCharges(invoice.getRoomCharges())
                .foodCharges(invoice.getFoodCharges())
                .serviceCharges(invoice.getServiceCharges())
                .taxAmount(invoice.getTaxAmount())
                .discountAmount(invoice.getDiscountAmount())
                .totalAmount(invoice.getTotalAmount())
                .paidAmount(invoice.getPaidAmount())
                .dueAmount(invoice.getDueAmount())
                .status(invoice.getStatus())
                .paymentStatus(invoice.getPaymentStatus())
                .pdfUrl(invoice.getPdfUrl())
                .notes(invoice.getNotes())
                .createdAt(invoice.getCreatedAt())
                .build();
    }
}