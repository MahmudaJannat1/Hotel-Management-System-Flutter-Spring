import 'package:sqflite/sqflite.dart';
import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:hotel_management_app/data/models/room_model.dart';

class RoomDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Room room) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'rooms',
      room.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAll(List<Room> rooms) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var room in rooms) {
      batch.insert(
        'rooms',
        room.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Room>> getAllRooms() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('rooms');

    return List.generate(maps.length, (i) {
      return Room.fromJson(maps[i]);
    });
  }

  Future<List<Room>> getAvailableRooms() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rooms',
      where: 'status = ?',
      whereArgs: ['AVAILABLE'],
    );

    return List.generate(maps.length, (i) {
      return Room.fromJson(maps[i]);
    });
  }

  Future<Room?> getRoomById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Room.fromJson(maps.first);
    }
    return null;
  }

  Future<int> update(Room room) async {
    final db = await _dbHelper.database;
    return await db.update(
      'rooms',
      room.toJson(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('rooms');
  }
}