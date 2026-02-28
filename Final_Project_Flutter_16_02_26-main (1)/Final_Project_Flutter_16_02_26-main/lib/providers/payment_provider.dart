import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/payment_model.dart';
import 'package:hotel_management_app/data/models/invoice_model.dart';
import 'package:hotel_management_app/data/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();

  List<Payment> _payments = [];
  List<Invoice> _invoices = [];
  Payment? _selectedPayment;
  Invoice? _selectedInvoice;
  bool _isLoading = false;
  String? _error;
  double _totalRevenue = 0.0;
  double _outstandingAmount = 0.0;

  List<Payment> get payments => _payments;
  List<Invoice> get invoices => _invoices;
  Payment? get selectedPayment => _selectedPayment;
  Invoice? get selectedInvoice => _selectedInvoice;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalRevenue => _totalRevenue;
  double get outstandingAmount => _outstandingAmount;

  // Statistics
  double get totalCompletedPayments => _payments
      .where((p) => p.paymentStatus == 'COMPLETED')
      .fold(0, (sum, p) => sum + p.amount);

  int get completedCount => _payments
      .where((p) => p.paymentStatus == 'COMPLETED')
      .length;

  int get pendingCount => _payments
      .where((p) => p.paymentStatus == 'PENDING')
      .length;

  int get refundedCount => _payments
      .where((p) => p.paymentStatus == 'REFUNDED')
      .length;

  // ========== Payment Methods ==========

  Future<bool> processPayment(Map<String, dynamic> paymentData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPayment = await _repository.processPayment(paymentData);
      _payments.add(newPayment);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAllPayments(int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payments = await _repository.getAllPayments(hotelId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadPaymentById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedPayment = await _repository.getPaymentById(id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadPaymentsByDateRange(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payments = await _repository.getPaymentsByDateRange(hotelId, startDate, endDate);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> refundPayment(int id, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPayment = await _repository.refundPayment(id, reason);
      final index = _payments.indexWhere((p) => p.id == id);
      if (index != -1) {
        final newList = List<Payment>.from(_payments);
        newList[index] = updatedPayment;
        _payments = newList;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ========== Invoice Methods ==========

  Future<bool> generateInvoice(Map<String, dynamic> invoiceData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newInvoice = await _repository.generateInvoice(invoiceData);
      _invoices.add(newInvoice);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadInvoiceByBooking(int bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedInvoice = await _repository.getInvoiceByBooking(bookingId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadInvoiceById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedInvoice = await _repository.getInvoiceById(id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadInvoicesByStatus(String status, int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _invoices = await _repository.getInvoicesByStatus(status, hotelId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> updateInvoiceStatus(int id, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedInvoice = await _repository.updateInvoiceStatus(id, status);
      final index = _invoices.indexWhere((i) => i.id == id);
      if (index != -1) {
        final newList = List<Invoice>.from(_invoices);
        newList[index] = updatedInvoice;
        _invoices = newList;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ========== Report Methods ==========

  Future<void> loadRevenueReport(int hotelId, DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _totalRevenue = await _repository.getTotalRevenue(hotelId, startDate, endDate);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadOutstandingAmount(int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _outstandingAmount = await _repository.getOutstandingAmount(hotelId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ========== Helper Methods ==========

  List<Payment> searchPayments(String query) {
    if (query.isEmpty) return _payments;
    return _payments.where((p) {
      return p.paymentNumber.toLowerCase().contains(query.toLowerCase()) ||
          p.bookingNumber.toLowerCase().contains(query.toLowerCase()) ||
          p.guestName.toLowerCase().contains(query.toLowerCase()) ||
          p.paymentMethod.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Payment> getPaymentsByStatus(String status) {
    return _payments.where((p) => p.paymentStatus == status).toList();
  }

  void selectPayment(Payment payment) {
    _selectedPayment = payment;
    notifyListeners();
  }

  void selectInvoice(Invoice invoice) {
    _selectedInvoice = invoice;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPayment = null;
    _selectedInvoice = null;
    notifyListeners();
  }
}