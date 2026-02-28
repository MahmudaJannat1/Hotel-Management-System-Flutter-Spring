import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/booking_model.dart';

class BookingApiService {
  final Dio _dio = ApiClient().dio;

  // ========== GET Methods ==========

  Future<List<Booking>> getAllBookings() async {
    try {
      final response = await _dio.get(ApiEndpoints.bookings);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }

  Future<Booking> getBookingById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.bookings}/$id');

      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Booking not found');
    } catch (e) {
      throw Exception('Failed to load booking: $e');
    }
  }

  Future<List<Booking>> getBookingsByGuest(int guestId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.bookings}/guest/$guestId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load bookings by guest: $e');
    }
  }

  Future<List<Booking>> getBookingsByRoom(int roomId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.bookings}/room/$roomId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load bookings by room: $e');
    }
  }

  Future<List<Booking>> getBookingsByStatus(String status) async {
    try {
      final response = await _dio.get('${ApiEndpoints.bookings}/status/$status');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load bookings by status: $e');
    }
  }

  Future<List<Booking>> getBookingsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.bookings}/range',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load bookings by date range: $e');
    }
  }

  Future<List<Booking>> getTodaysCheckIns() async {
    try {
      final response = await _dio.get('${ApiEndpoints.bookings}/today/checkins');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load today\'s check-ins: $e');
    }
  }

  Future<List<Booking>> getTodaysCheckOuts() async {
    try {
      final response = await _dio.get('${ApiEndpoints.bookings}/today/checkouts');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load today\'s check-outs: $e');
    }
  }

  // ========== POST Methods ==========

  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.bookings,
        data: bookingData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to create booking');
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // ========== PUT Methods ==========

  Future<Booking> updateBooking(int id, Map<String, dynamic> bookingData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.bookings}/$id',
        data: bookingData,
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to update booking');
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  // ========== PATCH Methods ==========

  Future<Booking> updateBookingStatus(int id, String status) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.bookings}/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to update booking status');
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // ========== DELETE Methods ==========

  Future<void> deleteBooking(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.bookings}/$id');
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  // ========== Check-in/Check-out Methods ==========

  Future<Booking> checkIn(int id) async {
    try {
      final response = await _dio.post('${ApiEndpoints.bookings}/$id/check-in');

      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to check in');
    } catch (e) {
      throw Exception('Failed to check in: $e');
    }
  }

  Future<Booking> checkOut(int id) async {
    try {
      final response = await _dio.post('${ApiEndpoints.bookings}/$id/check-out');

      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to check out');
    } catch (e) {
      throw Exception('Failed to check out: $e');
    }
  }

  Future<Booking> cancelBooking(int id) async {
    try {
      final response = await _dio.post('${ApiEndpoints.bookings}/$id/cancel');

      if (response.statusCode == 200) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Failed to cancel booking');
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }
}