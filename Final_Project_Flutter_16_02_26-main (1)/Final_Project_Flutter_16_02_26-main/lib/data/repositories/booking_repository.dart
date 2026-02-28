import 'package:hotel_management_app/data/models/booking_model.dart';
import 'package:hotel_management_app/data/remote/services/booking_api_service.dart';
import 'package:hotel_management_app/data/local/database/daos/booking_dao.dart';

class BookingRepository {
  final BookingApiService _apiService = BookingApiService();
  final BookingDao _bookingDao = BookingDao();

  // ========== API Methods (For Admin) ==========

  Future<List<Booking>> getAllBookings() async {
    try {
      return await _apiService.getAllBookings();
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }

  Future<Booking> getBookingById(int id) async {
    try {
      return await _apiService.getBookingById(id);
    } catch (e) {
      throw Exception('Failed to load booking: $e');
    }
  }

  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    try {
      return await _apiService.createBooking(bookingData);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<Booking> updateBooking(int id, Map<String, dynamic> bookingData) async {
    try {
      return await _apiService.updateBooking(id, bookingData);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  Future<Booking> updateBookingStatus(int id, String status) async {
    try {
      return await _apiService.updateBookingStatus(id, status);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  Future<void> deleteBooking(int id) async {
    try {
      await _apiService.deleteBooking(id);
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  Future<List<Booking>> getBookingsByGuest(int guestId) async {
    try {
      return await _apiService.getBookingsByGuest(guestId);
    } catch (e) {
      throw Exception('Failed to load bookings by guest: $e');
    }
  }

  Future<List<Booking>> getBookingsByRoom(int roomId) async {
    try {
      return await _apiService.getBookingsByRoom(roomId);
    } catch (e) {
      throw Exception('Failed to load bookings by room: $e');
    }
  }

  Future<List<Booking>> getBookingsByStatus(String status) async {
    try {
      return await _apiService.getBookingsByStatus(status);
    } catch (e) {
      throw Exception('Failed to load bookings by status: $e');
    }
  }

  Future<List<Booking>> getBookingsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _apiService.getBookingsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('Failed to load bookings by date range: $e');
    }
  }

  Future<List<Booking>> getTodaysCheckIns() async {
    try {
      return await _apiService.getTodaysCheckIns();
    } catch (e) {
      throw Exception('Failed to load today\'s check-ins: $e');
    }
  }

  Future<List<Booking>> getTodaysCheckOuts() async {
    try {
      return await _apiService.getTodaysCheckOuts();
    } catch (e) {
      throw Exception('Failed to load today\'s check-outs: $e');
    }
  }

  // ========== Local DB Methods (For Sync) ==========

  Future<void> syncBookings(List<Booking> bookings) async {
    try {
      await _bookingDao.deleteAll();
      for (var booking in bookings) {
        await _bookingDao.insert(booking);
      }
    } catch (e) {
      throw Exception('Failed to sync bookings: $e');
    }
  }

  Future<List<Booking>> getLocalBookings() async {
    try {
      return await _bookingDao.getAllBookings();
    } catch (e) {
      throw Exception('Failed to load local bookings: $e');
    }
  }

  Future<Booking?> getLocalBookingById(int id) async {
    try {
      return await _bookingDao.getBookingById(id);
    } catch (e) {
      throw Exception('Failed to load local booking: $e');
    }
  }

  Future<List<Booking>> getLocalBookingsByStatus(String status) async {
    try {
      return await _bookingDao.getBookingsByStatus(status);
    } catch (e) {
      throw Exception('Failed to load local bookings by status: $e');
    }
  }

  Future<List<Booking>> getLocalBookingsByGuest(int guestId) async {
    try {
      return await _bookingDao.getBookingsByGuest(guestId);
    } catch (e) {
      throw Exception('Failed to load local bookings by guest: $e');
    }
  }

  Future<List<Booking>> getLocalTodaysCheckIns() async {
    try {
      return await _bookingDao.getTodaysCheckIns();
    } catch (e) {
      throw Exception('Failed to load local today\'s check-ins: $e');
    }
  }

  Future<List<Booking>> getLocalTodaysCheckOuts() async {
    try {
      return await _bookingDao.getTodaysCheckOuts();
    } catch (e) {
      throw Exception('Failed to load local today\'s check-outs: $e');
    }
  }
}