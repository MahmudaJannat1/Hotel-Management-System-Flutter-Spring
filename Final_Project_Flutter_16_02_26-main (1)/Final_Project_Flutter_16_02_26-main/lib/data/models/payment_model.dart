import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Payment {
  final int id;
  final String paymentNumber;
  final int bookingId;
  final String bookingNumber;
  final String guestName;
  final String roomNumber;
  final double amount;
  final String paymentMethod; // CASH, CARD, BANK_TRANSFER, MOBILE_BANKING, ONLINE
  final String paymentStatus; // PENDING, COMPLETED, FAILED, REFUNDED
  final DateTime paymentDate;
  final String? transactionId;
  final String? cardLastFour;
  final String? bankName;
  final String? chequeNumber;
  final String? mobileBankingProvider;
  final String? mobileAccountNo;
  final String? reference;
  final String? notes;
  final String? receivedBy;
  final int? hotelId;

  Payment({
    required this.id,
    required this.paymentNumber,
    required this.bookingId,
    required this.bookingNumber,
    required this.guestName,
    required this.roomNumber,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
    this.transactionId,
    this.cardLastFour,
    this.bankName,
    this.chequeNumber,
    this.mobileBankingProvider,
    this.mobileAccountNo,
    this.reference,
    this.notes,
    this.receivedBy,
    this.hotelId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      paymentNumber: json['paymentNumber'] ?? '',
      bookingId: json['bookingId'] ?? 0,
      bookingNumber: json['bookingNumber'] ?? '',
      guestName: json['guestName'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      transactionId: json['transactionId'],
      cardLastFour: json['cardLastFour'],
      bankName: json['bankName'],
      chequeNumber: json['chequeNumber'],
      mobileBankingProvider: json['mobileBankingProvider'],
      mobileAccountNo: json['mobileAccountNo'],
      reference: json['reference'],
      notes: json['notes'],
      receivedBy: json['receivedBy'],
      hotelId: json['hotelId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentNumber': paymentNumber,
      'bookingId': bookingId,
      'bookingNumber': bookingNumber,
      'guestName': guestName,
      'roomNumber': roomNumber,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionId': transactionId,
      'cardLastFour': cardLastFour,
      'bankName': bankName,
      'chequeNumber': chequeNumber,
      'mobileBankingProvider': mobileBankingProvider,
      'mobileAccountNo': mobileAccountNo,
      'reference': reference,
      'notes': notes,
      'receivedBy': receivedBy,
      'hotelId': hotelId,
    };
  }

  Color get statusColor {
    switch (paymentStatus) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      case 'REFUNDED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (paymentStatus) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'FAILED':
        return Icons.error;
      case 'REFUNDED':
        return Icons.assignment_return;
      default:
        return Icons.help;
    }
  }
}