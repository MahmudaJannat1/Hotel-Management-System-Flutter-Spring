import 'package:sqflite/sqflite.dart';
import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:hotel_management_app/data/models/booking_model.dart';

class BookingDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ========== INSERT ==========

  Future<int> insert(Booking booking) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'bookings',
      _toMap(booking),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAll(List<Booking> bookings) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var booking in bookings) {
      batch.insert(
        'bookings',
        _toMap(booking),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  // ========== SELECT ==========

  Future<List<Booking>> getAllBookings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromJson(maps[i]);
    });
  }

  Future<Booking?> getBookingById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Booking.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Booking>> getBookingsByGuest(int guestId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'guestId = ?',
      whereArgs: [guestId],
      orderBy: 'checkInDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromJson(maps[i]);
    });
  }

  Future<List<Booking>> getBookingsByRoom(int roomId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'roomId = ?',
      whereArgs: [roomId],
      orderBy: 'checkInDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromJson(maps[i]);
    });
  }

  Future<List<Booking>> getBookingsByStatus(String status) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'checkInDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromJson(maps[i]);
    });
  }

  Future<List<Booking>> getBookingsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'checkInDate >= ? AND checkOutDate <= ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'checkInDate ASC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromJson(maps[i]);
    });
  }

  Future<List<Booking>> getTodaysCheckIns() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'checkInDate = ?',
      whereArgs: [todayStr],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromJson(maps[i]);
    });
  }

  Future<List<Booking>> getTodaysCheckOuts() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'checkOutDate = ?',
      whereArgs: [todayStr],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromJson(maps[i]);
    });
  }

  Future<List<Booking>> getUpcomingBookings({int days = 7}) async {
    final today = DateTime.now();
    final future = today.add(Duration(days: days));

    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final futureStr = '${future.year}-${future.month.toString().padLeft(2, '0')}-${future.day.toString().padLeft(2, '0')}';

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'checkInDate >= ? AND checkInDate <= ?',
      whereArgs: [todayStr, futureStr],
      orderBy: 'checkInDate ASC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromJson(maps[i]);
    });
  }

  Future<List<Booking>> searchBookings(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'bookingNumber LIKE ? OR guestName LIKE ? OR roomNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Booking.fromJson(maps[i]);
    });
  }

  // ========== UPDATE ==========

  Future<int> update(Booking booking) async {
    final db = await _dbHelper.database;
    return await db.update(
      'bookings',
      _toMap(booking),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> updateStatus(int id, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'bookings',
      {'status': status, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== DELETE ==========

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('bookings');
  }

  // ========== COUNT ==========

  Future<int> count() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM bookings');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countByStatus(String status) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'bookings',
      where: 'status = ?',
      whereArgs: [status],
    );
    return result.length;
  }

  // ========== HELPER METHODS ==========

  Map<String, dynamic> _toMap(Booking booking) {
    return {
      'id': booking.id,
      'bookingNumber': booking.bookingNumber,
      'guestId': booking.guestId,
      'guestName': booking.guestName,
      'roomId': booking.roomId,
      'roomNumber': booking.roomNumber,
      'roomType': booking.roomType,
      'checkInDate': booking.checkInDate.toIso8601String().split('T')[0],
      'checkOutDate': booking.checkOutDate.toIso8601String().split('T')[0],
      'numberOfGuests': booking.numberOfGuests,
      'status': booking.status,
      'totalAmount': booking.totalAmount,
      'advancePayment': booking.advancePayment,
      'dueAmount': booking.dueAmount,
      'paymentMethod': booking.paymentMethod,
      'specialRequests': booking.specialRequests,
      'createdAt': booking.createdAt.toIso8601String(),
    };
  }
}