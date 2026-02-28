import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/booking_model.dart';
import 'package:hotel_management_app/data/repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository = BookingRepository();

  List<Booking> _bookings = [];
  Booking? _selectedBooking;
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistics
  int get totalBookings => _bookings.length;
  int get pendingBookings => _bookings.where((b) => b.status == 'pending').length;
  int get confirmedBookings => _bookings.where((b) => b.status == 'confirmed').length;
  int get checkedInBookings => _bookings.where((b) => b.status == 'checked_in').length;
  int get checkedOutBookings => _bookings.where((b) => b.status == 'checked_out').length;
  int get cancelledBookings => _bookings.where((b) => b.status == 'cancelled').length;

  double get totalRevenue => _bookings
      .where((b) => b.status == 'checked_out')
      .fold(0, (sum, b) => sum + b.totalAmount);

  // Load all bookings
  Future<void> loadAllBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _repository.getAllBookings();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  // Load booking by ID
  Future<void> loadBookingById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedBooking = await _repository.getBookingById(id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  // Create new booking
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBooking = await _repository.createBooking(bookingData);
      _bookings.add(newBooking);
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

  // Update booking
  Future<bool> updateBooking(int id, Map<String, dynamic> bookingData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedBooking = await _repository.updateBooking(id, bookingData);

      // Update the list with new reference
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        final newList = List<Booking>.from(_bookings);
        newList[index] = updatedBooking;
        _bookings = newList;  // 🔥 new reference

        print('✅ Booking updated in list: ${updatedBooking.id}, Status: ${updatedBooking.status}');
      }

      _isLoading = false;
      notifyListeners();  // UI refresh
      return true;

    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('❌ Update error: $e');
      notifyListeners();
      return false;
    }
  }


  Future<bool> updateBookingStatus(int id, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedBooking = await _repository.updateBookingStatus(id, status);
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }
      if (_selectedBooking?.id == id) {
        _selectedBooking = updatedBooking;
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

  // Delete booking
  Future<bool> deleteBooking(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteBooking(id);
      _bookings.removeWhere((b) => b.id == id);
      if (_selectedBooking?.id == id) {
        _selectedBooking = null;
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

  // Filter bookings by status
  List<Booking> getBookingsByStatus(String status) {
    return _bookings.where((b) => b.status == status).toList();
  }

  // Filter bookings by guest
  List<Booking> getBookingsByGuest(int guestId) {
    return _bookings.where((b) => b.guestId == guestId).toList();
  }

  // Filter bookings by room
  List<Booking> getBookingsByRoom(int roomId) {
    return _bookings.where((b) => b.roomId == roomId).toList();
  }

  // Filter bookings by date range
  List<Booking> getBookingsByDateRange(DateTime start, DateTime end) {
    return _bookings.where((b) {
      return b.checkInDate.isAfter(start) && b.checkOutDate.isBefore(end);
    }).toList();
  }

  // Search bookings
  List<Booking> searchBookings(String query) {
    if (query.isEmpty) return _bookings;
    return _bookings.where((b) {
      return b.bookingNumber.toLowerCase().contains(query.toLowerCase()) ||
          b.guestName.toLowerCase().contains(query.toLowerCase()) ||
          b.roomNumber.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Clear selection
  void clearSelection() {
    _selectedBooking = null;
    notifyListeners();
  }

  // Today's check-ins
  List<Booking> getTodaysCheckIns() {
    final today = DateTime.now();
    return _bookings.where((b) {
      return b.checkInDate.year == today.year &&
          b.checkInDate.month == today.month &&
          b.checkInDate.day == today.day;
    }).toList();
  }

  // Today's check-outs
  List<Booking> getTodaysCheckOuts() {
    final today = DateTime.now();
    return _bookings.where((b) {
      return b.checkOutDate.year == today.year &&
          b.checkOutDate.month == today.month &&
          b.checkOutDate.day == today.day;
    }).toList();
  }

  // Upcoming bookings
  List<Booking> getUpcomingBookings({int days = 7}) {
    final today = DateTime.now();
    final future = today.add(Duration(days: days));
    return _bookings.where((b) {
      return b.checkInDate.isAfter(today) && b.checkInDate.isBefore(future);
    }).toList();
  }
}