import 'dart:ui';

import 'package:flutter/material.dart';

class Invoice {
  final int id;
  final String invoiceNumber;
  final int bookingId;
  final String bookingNumber;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String roomNumber;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfNights;
  final DateTime invoiceDate;
  final DateTime? dueDate;

  // Amounts
  final double roomCharges;
  final double foodCharges;
  final double serviceCharges;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;

  // Tax
  final double? taxRate;
  final String? taxDescription;

  // Status
  final String status; // DRAFT, SENT, PAID, PARTIALLY_PAID, OVERDUE, CANCELLED
  final String paymentStatus;

  final String? pdfUrl;
  final String? notes;
  final String? termsAndConditions;
  final String? generatedBy;
  final DateTime? sentAt;
  final int? hotelId;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.bookingId,
    required this.bookingNumber,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.roomNumber,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.invoiceDate,
    this.dueDate,
    required this.roomCharges,
    required this.foodCharges,
    required this.serviceCharges,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    this.taxRate,
    this.taxDescription,
    required this.status,
    required this.paymentStatus,
    this.pdfUrl,
    this.notes,
    this.termsAndConditions,
    this.generatedBy,
    this.sentAt,
    this.hotelId,
    required this.createdAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoiceNumber'] ?? '',
      bookingId: json['bookingId'] ?? 0,
      bookingNumber: json['bookingNumber'] ?? '',
      guestName: json['guestName'] ?? '',
      guestEmail: json['guestEmail'] ?? '',
      guestPhone: json['guestPhone'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      checkInDate: json['checkInDate'] != null
          ? DateTime.parse(json['checkInDate'])
          : DateTime.now(),
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'])
          : DateTime.now(),
      numberOfNights: json['numberOfNights'] ?? 0,
      invoiceDate: json['invoiceDate'] != null
          ? DateTime.parse(json['invoiceDate'])
          : DateTime.now(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      roomCharges: (json['roomCharges'] ?? 0).toDouble(),
      foodCharges: (json['foodCharges'] ?? 0).toDouble(),
      serviceCharges: (json['serviceCharges'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      dueAmount: (json['dueAmount'] ?? 0).toDouble(),
      taxRate: json['taxRate']?.toDouble(),
      taxDescription: json['taxDescription'],
      status: json['status'] ?? 'DRAFT',
      paymentStatus: json['paymentStatus'] ?? 'UNPAID',
      pdfUrl: json['pdfUrl'],
      notes: json['notes'],
      termsAndConditions: json['termsAndConditions'],
      generatedBy: json['generatedBy'],
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'])
          : null,
      hotelId: json['hotelId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Color get statusColor {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'SENT':
        return Colors.blue;
      case 'DRAFT':
        return Colors.grey;
      case 'OVERDUE':
        return Colors.red;
      case 'CANCELLED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}