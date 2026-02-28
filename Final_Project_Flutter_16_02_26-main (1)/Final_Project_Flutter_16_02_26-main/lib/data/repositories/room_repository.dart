import 'dart:io';

import 'package:hotel_management_app/data/models/room_model.dart';
import 'package:hotel_management_app/data/remote/services/room_api_service.dart';
import 'package:hotel_management_app/data/local/database/daos/room_dao.dart';

class RoomRepository {
  final RoomApiService _apiService = RoomApiService();
  final RoomDao _roomDao = RoomDao();

  // For Admin - get from API
  Future<List<Room>> getAllRoomsFromApi() async {
    return await _apiService.getAllRooms();
  }

  Future<Room> getRoomById(int id) async {
    return await _apiService.getRoomById(id);
  }

  Future<Room> createRoom(Map<String, dynamic> roomData) async {
    return await _apiService.createRoom(roomData);
  }

  Future<Room> updateRoom(int id, Map<String, dynamic> roomData) async {
    return await _apiService.updateRoom(id, roomData);
  }

  Future<void> deleteRoom(int id) async {
    await _apiService.deleteRoom(id);
  }

  Future<Room> updateRoomStatus(int id, String status) async {
    return await _apiService.updateRoomStatus(id, status);
  }

  Future<Room> updateRoomRate(int id, double rate) async {
    return await _apiService.updateRoomRate(id, rate);
  }

  Future<List<Room>> getRoomsByStatus(String status) async {
    return await _apiService.getRoomsByStatus(status);
  }

  Future<List<Room>> getAvailableRooms() async {
    return await _apiService.getAvailableRooms();
  }

  // For local DB (sync)
  Future<void> syncRooms(List<Room> rooms) async {
    await _roomDao.deleteAll();
    for (var room in rooms) {
      await _roomDao.insert(room);
    }
  }

  Future<List<Room>> getLocalRooms() async {
    return await _roomDao.getAllRooms();
  }

  Future<List<Room>> getLocalAvailableRooms() async {
    return await _roomDao.getAvailableRooms();
  }

  // Add this method
  Future<List<Room>> searchRooms({
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
  }) async {
    // For now, just return available rooms
    // In real app, you'd call an API with these params
    return await _apiService.getAvailableRooms();
  }

  Future<Room> createRoomWithImage(Map<String, dynamic> roomData, File? imageFile) async {
    return await _apiService.createRoomWithImage(roomData, imageFile);
  }

  Future<Room> updateRoomWithImage(int id, Map<String, dynamic> roomData, File? imageFile) async {
    return await _apiService.updateRoomWithImage(id, roomData, imageFile);
  }
}

