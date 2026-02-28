import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/guest_room_model.dart';
import 'package:hotel_management_app/data/models/guest_booking_model.dart';
import 'package:hotel_management_app/data/models/guest_user_model.dart';
import 'package:hotel_management_app/data/repositories/guest_repository.dart';

import '../data/local/database/database_helper.dart';

class GuestProvider extends ChangeNotifier {
  final GuestRepository _repository = GuestRepository();
  bool get isLoggedIn => _currentUser != null;


  List<GuestRoom> _rooms = [];
  List<GuestBooking> _bookings = [];
  GuestRoom? _selectedRoom;
  GuestBooking? _selectedBooking;
  GuestUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<GuestRoom> get rooms => _rooms;
  List<GuestBooking> get bookings => _bookings;
  GuestRoom? get selectedRoom => _selectedRoom;
  GuestBooking? get selectedBooking => _selectedBooking;
  GuestUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ========== User Methods ==========

  Future<void> checkLoggedInUser() async {
    try {
      _currentUser = await _repository.getLoggedInUser();
      print('✅ Checked logged in user: ${_currentUser?.email ?? 'None'}');
    } catch (e) {
      print('❌ Error checking logged in user: $e');
    }
    notifyListeners();
  }

// guest_provider.dart

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _repository.getUserByEmail(email);

      if (user != null && user.password == password) {  // ✅ password check
        await _repository.logoutAll();
        final updatedUser = GuestUser(
          id: user.id,
          name: user.name,
          email: user.email,
          password: user.password,
          phone: user.phone,
          address: user.address,
          isLoggedIn: true,
        );
        await _repository.updateUser(updatedUser);
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Invalid email or password');
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(GuestUser user) async {
    print('📝 Register attempt for: ${user.email}');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _repository.createUser(user);
      print('✅ User created with ID: $id');

      if (id > 0) {
        print('🔄 Auto-login after registration');

        return await login(user.email, user.password);
      }
      throw Exception('Registration failed');
    } catch (e) {
      print('❌ Register error: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logoutAll();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile(GuestUser user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('========== UPDATE PROFILE ==========');
      print('🔄 Updating user: ${user.id} - ${user.name}');
      print('👤 User data: ${user.toMap()}');

      final count = await _repository.updateUser(user);
      print('📊 Repository returned count: $count');

      if (count > 0) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        print('✅ Profile update successful!');
        print('====================================');
        return true;
      }
      throw Exception('Update failed - count = $count');
    } catch (e) {
      print('❌ Update error: $e');
      print('====================================');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ========== Room Methods ==========

  Future<void> loadAllRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rooms = await _repository.getAllRooms();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }






// GuestProvider.dart - loadAvailableRooms মেথডের শুরুতে

  Future<void> loadAvailableRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ফোর্স রিসেট - শুধু একবারের জন্য
      final dbHelper = DatabaseHelper();
      // await dbHelper.forceResetDatabase();  // এই লাইনটি যোগ করুন

      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'rooms',
        where: 'status = ?',
        whereArgs: ['AVAILABLE'],
      );

      print('Total rooms found: ${result.length}');

      _rooms = result.map((map) {
        print('Room data: ${map['roomNumber']} - Images: ${map['images']}');
        return GuestRoom.fromMap(map);
      }).toList();

      for (var room in _rooms) {
        print('🏨 Room ${room.roomNumber} has ${room.images.length} images: ${room.images}');
      }

      _isLoading = false;
      _error = null;
    } catch (e) {
      print('Error loading rooms: $e');
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> searchRooms({
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    String? roomType,
    double? maxPrice,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rooms = await _repository.searchRooms(
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        roomType: roomType,
        maxPrice: maxPrice,
      );
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadRoomById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedRoom = await _repository.getRoomById(id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ========== Booking Methods ==========

  Future<bool> createBooking(GuestBooking booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Creating booking in provider: ${booking.bookingNumber}');
      final id = await _repository.createBooking(booking);
      print('✅ Booking created with ID: $id');

      if (id > 0) {
        // ✅ নতুন booking লোকাল লিস্টে যোগ করুন
        _bookings.add(booking);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Failed to create booking - ID invalid');
    } catch (e) {
      print('❌ Booking error in provider: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }


  Future<void> loadBookingsByGuest(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📚 Loading bookings for email: $email');
      _bookings = await _repository.getBookingsByGuest(email);
      print('✅ Loaded ${_bookings.length} bookings');

      // ডিবাগ: bookings প্রিন্ট করুন
      for (var booking in _bookings) {
        print('   - Booking: ${booking.bookingNumber}, Status: ${booking.status}');
      }

      _isLoading = false;
    } catch (e) {
      print('❌ Error loading bookings: $e');
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

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

  Future<bool> cancelBooking(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final count = await _repository.cancelBooking(id);
      if (count > 0) {
        if (_currentUser != null) {
          _bookings = await _repository.getBookingsByGuest(_currentUser!.email);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Failed to cancel booking');
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ========== Helper Methods ==========

  List<String> getUniqueRoomTypes() {
    return _rooms.map((r) => r.roomType).toSet().toList();
  }

  double getMinPrice() {
    if (_rooms.isEmpty) return 0;
    return _rooms.map((r) => r.price).reduce((a, b) => a < b ? a : b);
  }

  double getMaxPrice() {
    if (_rooms.isEmpty) return 10000;
    return _rooms.map((r) => r.price).reduce((a, b) => a > b ? a : b);
  }

  void selectRoom(GuestRoom room) {
    _selectedRoom = room;
    notifyListeners();
  }

  void selectBooking(GuestBooking booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRoom = null;
    _selectedBooking = null;
    notifyListeners();
  }

// GuestProvider.dart - একটি টেস্ট ফাংশন যোগ করুন

  Future<void> checkDatabaseImages() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('rooms');

      print('========== DATABASE CHECK ==========');
      for (var row in result) {
        print('Room ID: ${row['id']}, Number: ${row['roomNumber']}');
        print('Images from DB: ${row['images']}');
        print('---');
      }
      print('====================================');
    } catch (e) {
      print('Error checking DB: $e');
    }
  }

}





extension on GuestBooking {
  GuestBooking copyWith({String? status}) {
    return GuestBooking(
      id: id,
      bookingNumber: bookingNumber,
      roomId: roomId,
      roomNumber: roomNumber,
      roomType: roomType,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      numberOfGuests: numberOfGuests,
      status: status ?? this.status,
      totalAmount: totalAmount,
      advancePayment: advancePayment,
      dueAmount: dueAmount,
      paymentMethod: paymentMethod,
      specialRequests: specialRequests,
      guestName: guestName,
      guestEmail: guestEmail,
      guestPhone: guestPhone,
      createdAt: createdAt,
      hotelId: hotelId,
    );
  }


}