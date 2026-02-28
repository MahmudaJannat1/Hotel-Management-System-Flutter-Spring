import 'package:hotel_management_app/data/models/payment_model.dart';
import 'package:hotel_management_app/data/models/invoice_model.dart';
import 'package:hotel_management_app/data/remote/services/payment_api_service.dart';

class PaymentRepository {
  final PaymentApiService _apiService = PaymentApiService();

  // ========== Payment Methods ==========

  Future<Payment> processPayment(Map<String, dynamic> paymentData) async {
    try {
      return await _apiService.processPayment(paymentData);
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  Future<List<Payment>> getAllPayments(int hotelId) async {
    try {
      return await _apiService.getAllPayments(hotelId);
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  Future<Payment> getPaymentById(int id) async {
    try {
      return await _apiService.getPaymentById(id);
    } catch (e) {
      throw Exception('Failed to load payment: $e');
    }
  }

  Future<List<Payment>> getPaymentsByBooking(int bookingId) async {
    try {
      return await _apiService.getPaymentsByBooking(bookingId);
    } catch (e) {
      throw Exception('Failed to load payments by booking: $e');
    }
  }

  Future<List<Payment>> getPaymentsByDateRange(
      int hotelId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      return await _apiService.getPaymentsByDateRange(hotelId, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to load payments by date range: $e');
    }
  }

  Future<Payment> refundPayment(int id, String reason) async {
    try {
      return await _apiService.refundPayment(id, reason);
    } catch (e) {
      throw Exception('Failed to refund payment: $e');
    }
  }

  // ========== Invoice Methods ==========

  Future<Invoice> generateInvoice(Map<String, dynamic> invoiceData) async {
    try {
      return await _apiService.generateInvoice(invoiceData);
    } catch (e) {
      throw Exception('Failed to generate invoice: $e');
    }
  }

  Future<Invoice> getInvoiceByBooking(int bookingId) async {
    try {
      return await _apiService.getInvoiceByBooking(bookingId);
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }

  Future<Invoice> getInvoiceById(int id) async {
    try {
      return await _apiService.getInvoiceById(id);
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }

  Future<List<Invoice>> getInvoicesByStatus(String status, int hotelId) async {
    try {
      return await _apiService.getInvoicesByStatus(status, hotelId);
    } catch (e) {
      throw Exception('Failed to load invoices by status: $e');
    }
  }

  Future<Invoice> updateInvoiceStatus(int id, String status) async {
    try {
      return await _apiService.updateInvoiceStatus(id, status);
    } catch (e) {
      throw Exception('Failed to update invoice status: $e');
    }
  }

  // ========== Report Methods ==========

  Future<double> getTotalRevenue(int hotelId, DateTime startDate, DateTime endDate) async {
    try {
      return await _apiService.getTotalRevenue(hotelId, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to get total revenue: $e');
    }
  }

  Future<double> getOutstandingAmount(int hotelId) async {
    try {
      return await _apiService.getOutstandingAmount(hotelId);
    } catch (e) {
      throw Exception('Failed to get outstanding amount: $e');
    }
  }
}