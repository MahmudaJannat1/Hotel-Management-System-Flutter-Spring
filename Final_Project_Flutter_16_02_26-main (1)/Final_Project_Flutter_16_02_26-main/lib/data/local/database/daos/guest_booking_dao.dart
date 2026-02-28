import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:hotel_management_app/data/models/guest_booking_model.dart';
import 'package:sqflite/sqflite.dart';

class GuestBookingDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ========== INSERT ==========

// guest_booking_dao.dart

  Future<int> insert(GuestBooking booking) async {
    final db = await _dbHelper.database;
    print('📝 Inserting booking: ${booking.bookingNumber}');

    try {
      // আগে থেকে bookingNumber আছে কিনা চেক করুন
      final existing = await db.query(
        'guest_bookings',
        where: 'bookingNumber = ?',
        whereArgs: [booking.bookingNumber],
      );

      if (existing.isNotEmpty) {
        print('⚠️ Booking number already exists: ${booking.bookingNumber}');
        return -1; // duplicate
      }

      // id ফিল্ড বাদ দিয়ে insert করুন (AUTOINCREMENT নিজে থেকে কাজ করবে)
      final id = await db.insert(
        'guest_bookings',
        booking.toMap(), // এখন id 0 হলে exclude হবে
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Inserted with ID: $id');
      return id;
    } catch (e) {
      print('❌ Insert error: $e');
      return 0;
    }
  }


  // ========== SELECT ==========

  Future<List<GuestBooking>> getAllBookings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return GuestBooking.fromMap(maps[i]);
    });
  }

  Future<GuestBooking?> getBookingById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return GuestBooking.fromMap(maps.first);
    }
    return null;
  }

  Future<GuestBooking?> getBookingByNumber(String bookingNumber) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'bookingNumber = ?',
      whereArgs: [bookingNumber],
    );

    if (maps.isNotEmpty) {
      return GuestBooking.fromMap(maps.first);
    }
    return null;
  }

  Future<List<GuestBooking>> getBookingsByGuest(String guestEmail) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'guestEmail = ?',
      whereArgs: [guestEmail],
      orderBy: 'checkInDate DESC',
    );

    return List.generate(maps.length, (i) {
      return GuestBooking.fromMap(maps[i]);
    });
  }

  Future<List<GuestBooking>> getBookingsByRoom(int roomId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'roomId = ?',
      whereArgs: [roomId],
      orderBy: 'checkInDate DESC',
    );

    return List.generate(maps.length, (i) {
      return GuestBooking.fromMap(maps[i]);
    });
  }

  Future<List<GuestBooking>> getBookingsByStatus(String status) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'checkInDate DESC',
    );

    return List.generate(maps.length, (i) {
      return GuestBooking.fromMap(maps[i]);
    });
  }

  Future<List<GuestBooking>> getUpcomingBookings(String guestEmail) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'guestEmail = ? AND checkInDate >= ? AND status != ?',
      whereArgs: [guestEmail, todayStr, 'cancelled'],
      orderBy: 'checkInDate ASC',
    );

    return List.generate(maps.length, (i) {
      return GuestBooking.fromMap(maps[i]);
    });
  }

  Future<List<GuestBooking>> getPastBookings(String guestEmail) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'guestEmail = ? AND checkOutDate < ?',
      whereArgs: [guestEmail, todayStr],
      orderBy: 'checkInDate DESC',
    );

    return List.generate(maps.length, (i) {
      return GuestBooking.fromMap(maps[i]);
    });
  }

  Future<List<GuestBooking>> getTodaysCheckIns() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'checkInDate = ?',
      whereArgs: [todayStr],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return GuestBooking.fromMap(maps[i]);
    });
  }

  Future<List<GuestBooking>> getTodaysCheckOuts() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'checkOutDate = ?',
      whereArgs: [todayStr],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return GuestBooking.fromMap(maps[i]);
    });
  }

  Future<List<GuestBooking>> searchBookings(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guest_bookings',
      where: 'bookingNumber LIKE ? OR guestName LIKE ? OR roomNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return GuestBooking.fromMap(maps[i]);
    });
  }

  // ========== UPDATE ==========

  Future<int> update(GuestBooking booking) async {
    final db = await _dbHelper.database;
    return await db.update(
      'guest_bookings',
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> updateStatus(int id, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'guest_bookings',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CANCEL BOOKING ==========

  Future<int> cancelBooking(int id) async {
    return await updateStatus(id, 'cancelled');
  }

  // ========== DELETE ==========

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'guest_bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('guest_bookings');
  }

  // ========== COUNT ==========

  Future<int> count() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM guest_bookings');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countByStatus(String status) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'guest_bookings',
      where: 'status = ?',
      whereArgs: [status],
    );
    return result.length;
  }
}