import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/room_model.dart';
import 'package:hotel_management_app/data/repositories/room_repository.dart';

class RoomProvider extends ChangeNotifier {
  final RoomRepository _repository = RoomRepository();

  List<Room> _rooms = [];
  bool _isLoading = false;
  String? _error;
  Room? _selectedRoom;

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Room? get selectedRoom => _selectedRoom;

  // Statistics
  int get totalRooms => _rooms.length;
  int get availableRooms => _rooms.where((r) => r.status == 'AVAILABLE').length;
  int get occupiedRooms => _rooms.where((r) => r.status == 'OCCUPIED').length;
  int get maintenanceRooms => _rooms.where((r) => r.status == 'MAINTENANCE').length;
  int get reservedRooms => _rooms.where((r) => r.status == 'RESERVED').length;
  double get occupancyRate => totalRooms > 0 ? (occupiedRooms / totalRooms * 100) : 0;

  Future<void> loadAllRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rooms = await _repository.getAllRoomsFromApi();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }


// এই method দুটি যোগ করুন আপনার RoomProvider class-এর ভিতরে

  Future<bool> createRoomWithImage(Map<String, dynamic> roomData, File? imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRoom = await _repository.createRoomWithImage(roomData, imageFile);
      _rooms.add(newRoom);
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

  Future<bool> updateRoomWithImage(int id, Map<String, dynamic> roomData, File? imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedRoom = await _repository.updateRoomWithImage(id, roomData, imageFile);
      final index = _rooms.indexWhere((r) => r.id == id);
      if (index != -1) {
        _rooms[index] = updatedRoom;
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

  // ✅ Add this method for available rooms
  Future<void> loadAvailableRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rooms = await _repository.getAvailableRooms();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ✅ Add this method for searching rooms
  Future<void> searchRooms({
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rooms = await _repository.searchRooms(
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
      );
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createRoom(Map<String, dynamic> roomData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRoom = await _repository.createRoom(roomData);
      _rooms.add(newRoom);
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

  Future<bool> updateRoom(int id, Map<String, dynamic> roomData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedRoom = await _repository.updateRoom(id, roomData);
      final index = _rooms.indexWhere((r) => r.id == id);
      if (index != -1) {
        _rooms[index] = updatedRoom;
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

// room_provider.dart e deleteRoom method:

// room_provider.dart - Fixed version:

  Future<bool> deleteRoom(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteRoom(id);
      _rooms.removeWhere((r) => r.id == id);
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

  Future<bool> updateRoomStatus(int id, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedRoom = await _repository.updateRoomStatus(id, status);
      final index = _rooms.indexWhere((r) => r.id == id);
      if (index != -1) {
        _rooms[index] = updatedRoom;
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

  Future<bool> updateRoomRate(int id, double rate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedRoom = await _repository.updateRoomRate(id, rate);
      final index = _rooms.indexWhere((r) => r.id == id);
      if (index != -1) {
        _rooms[index] = updatedRoom;
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

  void selectRoom(Room room) {
    _selectedRoom = room;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRoom = null;
    notifyListeners();
  }

  List<Room> getRoomsByStatus(String status) {
    return _rooms.where((r) => r.status == status).toList();
  }

  List<Room> getAvailableRoomsList() {
    return _rooms.where((r) => r.status == 'AVAILABLE').toList();
  }

  List<Room> searchRoomsList(String query) {
    if (query.isEmpty) return _rooms;
    return _rooms.where((r) {
      return r.roomNumber.toLowerCase().contains(query.toLowerCase()) ||
          r.roomType.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}