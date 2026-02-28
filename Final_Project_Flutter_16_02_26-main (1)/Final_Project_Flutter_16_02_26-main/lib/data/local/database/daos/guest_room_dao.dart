import 'package:sqflite/sqflite.dart';
import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:hotel_management_app/data/models/guest_room_model.dart';

class GuestRoomDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertAll(List<GuestRoom> rooms) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var room in rooms) {
      batch.insert(
        'rooms',
        room.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<GuestRoom>> getAllRooms() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('rooms');

    return List.generate(maps.length, (i) {
      return GuestRoom.fromMap(maps[i]);
    });
  }

  Future<List<GuestRoom>> getAvailableRooms() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rooms',
      where: "status = 'AVAILABLE'",
      orderBy: 'price ASC',
    );

    return List.generate(maps.length, (i) {
      return GuestRoom.fromMap(maps[i]);
    });
  }


  Future<GuestRoom?> getRoomById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return GuestRoom.fromMap(maps.first);
    }
    return null;
  }

  Future<List<GuestRoom>> searchRooms({
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    String? roomType,
    double? maxPrice,
  }) async {
    final db = await _dbHelper.database;

    // Start with base query - using 'status' instead of 'isAvailable'
    String whereClause = "status = 'AVAILABLE'";  // 🔥 এই line টা পরিবর্তন করুন
    List<dynamic> whereArgs = [];

    // Add guest filter
    if (guests != null) {
      whereClause += ' AND maxOccupancy >= ?';
      whereArgs.add(guests);
    }

    // Add room type filter
    if (roomType != null && roomType != 'all' && roomType != 'Any Type') {
      whereClause += ' AND roomType = ?';
      whereArgs.add(roomType);
    }

    // Add price filter
    if (maxPrice != null && maxPrice > 0) {
      whereClause += ' AND price <= ?';
      whereArgs.add(maxPrice);
    }

    print('Search query: $whereClause');
    print('Args: $whereArgs');

    final List<Map<String, dynamic>> maps = await db.query(
      'rooms',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'price ASC',
    );

    print('Found ${maps.length} rooms');

    return List.generate(maps.length, (i) {
      return GuestRoom.fromMap(maps[i]);
    });
  }



  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('rooms');
  }
}