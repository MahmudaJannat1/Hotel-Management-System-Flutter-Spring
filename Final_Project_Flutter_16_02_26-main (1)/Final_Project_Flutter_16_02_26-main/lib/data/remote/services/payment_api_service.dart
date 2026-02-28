import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/payment_model.dart';
import 'package:hotel_management_app/data/models/invoice_model.dart';

class PaymentApiService {
  final Dio _dio = ApiClient().dio;

  // ========== Payment Endpoints ==========

  Future<Payment> processPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.payments}/process',
        data: paymentData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Payment.fromJson(response.data);
      }
      throw Exception('Failed to process payment');
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  Future<List<Payment>> getAllPayments(int hotelId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.payments,
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Payment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  Future<Payment> getPaymentById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.payments}/$id');

      if (response.statusCode == 200) {
        return Payment.fromJson(response.data);
      }
      throw Exception('Payment not found');
    } catch (e) {
      throw Exception('Failed to load payment: $e');
    }
  }

  Future<List<Payment>> getPaymentsByBooking(int bookingId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.payments}/booking/$bookingId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Payment.fromJson(json)).toList();
      }
      return [];
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
      final response = await _dio.get(
        '${ApiEndpoints.payments}/date-range',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Payment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load payments by date range: $e');
    }
  }

  Future<Payment> refundPayment(int id, String reason) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.payments}/$id/refund',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        return Payment.fromJson(response.data);
      }
      throw Exception('Failed to refund payment');
    } catch (e) {
      throw Exception('Failed to refund payment: $e');
    }
  }

  // ========== Invoice Endpoints ==========

  Future<Invoice> generateInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.payments}/invoices/generate',
        data: invoiceData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Invoice.fromJson(response.data);
      }
      throw Exception('Failed to generate invoice');
    } catch (e) {
      throw Exception('Failed to generate invoice: $e');
    }
  }

  Future<Invoice> getInvoiceByBooking(int bookingId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.payments}/invoices/booking/$bookingId',
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(response.data);
      }
      throw Exception('Invoice not found');
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }

  Future<Invoice> getInvoiceById(int id) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.payments}/invoices/$id',
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(response.data);
      }
      throw Exception('Invoice not found');
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }

  Future<List<Invoice>> getInvoicesByStatus(String status, int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.payments}/invoices/status/$status',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Invoice.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load invoices by status: $e');
    }
  }

  Future<Invoice> updateInvoiceStatus(int id, String status) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.payments}/invoices/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(response.data);
      }
      throw Exception('Failed to update invoice status');
    } catch (e) {
      throw Exception('Failed to update invoice status: $e');
    }
  }

  // ========== Report Endpoints ==========

  Future<double> getTotalRevenue(int hotelId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.payments}/reports/revenue',
        queryParameters: {
          'hotelId': hotelId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return (response.data as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      throw Exception('Failed to get total revenue: $e');
    }
  }

  Future<double> getOutstandingAmount(int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.payments}/reports/outstanding',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        return (response.data as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      throw Exception('Failed to get outstanding amount: $e');
    }
  }
}