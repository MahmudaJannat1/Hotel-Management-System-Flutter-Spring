import 'package:hotel_management_app/data/models/guest_model.dart';
import 'package:hotel_management_app/data/remote/services/guest_api_service.dart';
//
// import 'package:hotel_management_app/data/local/database/daos/guest_room_dao.dart';
// import 'package:hotel_management_app/data/local/database/daos/guest_booking_dao.dart';
// import 'package:hotel_management_app/data/models/guest_room_model.dart';
// import 'package:hotel_management_app/data/models/guest_booking_model.dart';
//
// class GuestRepository {
//   final GuestApiService _apiService = GuestApiService();
//
//   final GuestRoomDao _roomDao = GuestRoomDao();
//   final GuestBookingDao _bookingDao = GuestBookingDao();
//
//   Future<List<Guest>> getAllGuests() async {
//     try {
//       return await _apiService.getAllGuests();
//     } catch (e) {
//       throw Exception('Failed to load guests: $e');
//     }
//   }
//
//   Future<Guest> getGuestById(int id) async {
//     try {
//       return await _apiService.getGuestById(id);
//     } catch (e) {
//       throw Exception('Failed to load guest: $e');
//     }
//   }
//
//   Future<List<Guest>> searchGuests(String query) async {
//     try {
//       return await _apiService.searchGuests(query);
//     } catch (e) {
//       throw Exception('Failed to search guests: $e');
//     }
//   }
//
//   // ========== Room Methods ==========
//
//   Future<List<GuestRoom>> getAllRooms() async {
//     return await _roomDao.getAllRooms();
//   }
//
//   Future<List<GuestRoom>> getAvailableRooms() async {
//     return await _roomDao.getAvailableRooms();
//   }
//
//   Future<GuestRoom?> getRoomById(int id) async {
//     return await _roomDao.getRoomById(id);
//   }
//
//   Future<List<GuestRoom>> searchRooms({
//     DateTime? checkIn,
//     DateTime? checkOut,
//     int? guests,
//     String? roomType,
//     double? maxPrice,
//   }) async {
//     return await _roomDao.searchRooms(
//       checkIn: checkIn,
//       checkOut: checkOut,
//       guests: guests,
//       roomType: roomType,
//       maxPrice: maxPrice,
//     );
//   }
//
//   Future<void> syncRooms(List<GuestRoom> rooms) async {
//     await _roomDao.deleteAll();
//     await _roomDao.insertAll(rooms);
//   }
//
//   // ========== Booking Methods ==========
//
//   Future<int> createBooking(GuestBooking booking) async {
//     return await _bookingDao.insert(booking);
//   }
//
//   Future<List<GuestBooking>> getBookingsByGuest(String email) async {
//     return await _bookingDao.getBookingsByGuest(email);
//   }
//
//   Future<GuestBooking?> getBookingByNumber(String bookingNumber) async {
//     return await _bookingDao.getBookingByNumber(bookingNumber);
//   }
//
//   Future<GuestBooking?> getBookingById(int id) async {
//     return await _bookingDao.getBookingById(id);
//   }
//
//   Future<List<GuestBooking>> getUpcomingBookings(String email) async {
//     return await _bookingDao.getUpcomingBookings(email);
//   }
//
//   Future<List<GuestBooking>> getPastBookings(String email) async {
//     return await _bookingDao.getPastBookings(email);
//   }
//
//   Future<int> cancelBooking(int id) async {
//     return await _bookingDao.cancelBooking(id);
//   }
//
//   Future<void> syncBookings(List<GuestBooking> bookings) async {
//     await _bookingDao.deleteAll();
//     for (var booking in bookings) {
//       await _bookingDao.insert(booking);
//     }
//   }
// }


import 'package:hotel_management_app/data/local/database/daos/guest_room_dao.dart';
import 'package:hotel_management_app/data/local/database/daos/guest_booking_dao.dart';
import 'package:hotel_management_app/data/local/database/daos/guest_user_dao.dart';
import 'package:hotel_management_app/data/models/guest_room_model.dart';
import 'package:hotel_management_app/data/models/guest_booking_model.dart';
import 'package:hotel_management_app/data/models/guest_user_model.dart';

import '../models/guest_model.dart';

class GuestRepository {
  final GuestRoomDao _roomDao = GuestRoomDao();
  final GuestBookingDao _bookingDao = GuestBookingDao();
  final GuestUserDao _userDao = GuestUserDao();
  final GuestApiService _apiService = GuestApiService();



  // ========== User Methods ==========

  Future<GuestUser?> getUserByEmail(String email) => _userDao.getUserByEmail(email);
  Future<int> createUser(GuestUser user) => _userDao.insert(user);

  Future<int> updateUser(GuestUser user) async {
    print('📦 Repository: Updating guest user ${user.id}');
    final result = await _userDao.update(user);
    print('📦 Repository update result: $result');
    return result;
  }

  Future<GuestUser?> getLoggedInUser() => _userDao.getLoggedInUser();
  Future<void> logoutAll() => _userDao.logoutAll();


  // ========== Room Methods ==========

  Future<List<GuestRoom>> getAllRooms() => _roomDao.getAllRooms();
  Future<List<GuestRoom>> getAvailableRooms() => _roomDao.getAvailableRooms();
  Future<GuestRoom?> getRoomById(int id) => _roomDao.getRoomById(id);

  Future<List<GuestRoom>> searchRooms({
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    String? roomType,
    double? maxPrice,
  }) => _roomDao.searchRooms(
    checkIn: checkIn,
    checkOut: checkOut,
    guests: guests,
    roomType: roomType,
    maxPrice: maxPrice,
  );

  Future<List<Guest>> getAllGuests() async {
     try {
       return await _apiService.getAllGuests();
     } catch (e) {
       throw Exception('Failed to load guests: $e');
     }
  }

  // ========== Booking Methods ==========

  Future<int> createBooking(GuestBooking booking) async {
    print('📦 Repository: Creating booking');
    return await _bookingDao.insert(booking);
  }

  Future<List<GuestBooking>> getBookingsByGuest(String email) async {
    return await _bookingDao.getBookingsByGuest(email);
  }

  Future<GuestBooking?> getBookingByNumber(String bookingNumber) => _bookingDao.getBookingByNumber(bookingNumber);
  Future<GuestBooking?> getBookingById(int id) => _bookingDao.getBookingById(id);
  Future<List<GuestBooking>> getUpcomingBookings(String email) => _bookingDao.getUpcomingBookings(email);
  Future<List<GuestBooking>> getPastBookings(String email) => _bookingDao.getPastBookings(email);
  Future<int> cancelBooking(int id) => _bookingDao.cancelBooking(id);
}
