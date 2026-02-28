import 'package:http_parser/http_parser.dart';  // MediaType-এর জন্য
import 'dart:convert';  // jsonEncode-এর জন্য
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/room_model.dart';

import '../../local/preferences/shared_prefs_helper.dart';

class RoomApiService {
  final Dio _dio = ApiClient().dio;

  Future<List<Room>> getAllRooms() async {
    try {
      final response = await _dio.get(ApiEndpoints.rooms);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Room.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load rooms: $e');
    }
  }

  Future<Room> getRoomById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.rooms}/$id');

      if (response.statusCode == 200) {
        return Room.fromJson(response.data);
      }
      throw Exception('Room not found');
    } catch (e) {
      throw Exception('Failed to load room: $e');
    }
  }

  Future<Room> createRoom(Map<String, dynamic> roomData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.rooms,
        data: roomData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Room.fromJson(response.data);
      }
      throw Exception('Failed to create room');
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  Future<Room> updateRoom(int id, Map<String, dynamic> roomData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.rooms}/$id',
        data: roomData,
      );

      if (response.statusCode == 200) {
        return Room.fromJson(response.data);
      }
      throw Exception('Failed to update room');
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }

// room_api_service.dart e delete method check koro:

// room_api_service.dart e delete method:

  Future<void> deleteRoom(int id) async {
    try {
      print('🗑️ Deleting room ID: $id');

      final response = await _dio.delete(
        '${ApiEndpoints.rooms}/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${SharedPrefsHelper.getToken()}',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            return status! < 500;  // Accept 400-499 as valid responses
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Room deleted successfully');
        return;
      } else if (response.statusCode == 400) {
        print('❌ Bad request: ${response.data}');
        throw Exception('Invalid request: ${response.data}');
      } else {
        throw Exception('Failed to delete room: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Delete DioException: ${e.response?.data}');
      throw Exception('Delete failed: ${e.response?.data ?? e.message}');
    }
  }


  Future<Room> updateRoomStatus(int id, String status) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.rooms}/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return Room.fromJson(response.data);
      }
      throw Exception('Failed to update room status');
    } catch (e) {
      throw Exception('Failed to update room status: $e');
    }
  }

  Future<Room> updateRoomRate(int id, double rate) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.rooms}/$id/rate?rate=$rate',
      );

      if (response.statusCode == 200) {
        return Room.fromJson(response.data);
      }
      throw Exception('Failed to update room rate');
    } catch (e) {
      throw Exception('Failed to update room rate: $e');
    }
  }

  Future<List<Room>> getRoomsByStatus(String status) async {
    try {
      final response = await _dio.get('${ApiEndpoints.rooms}/status/$status');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Room.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load rooms by status: $e');
    }
  }

  Future<List<Room>> getAvailableRooms() async {
    try {
      final response = await _dio.get('${ApiEndpoints.rooms}/hotel/1/available');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Room.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load available rooms: $e');
    }
  }

  Future<Room> createRoomWithImage(Map<String, dynamic> roomData, File? imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'roomData': MultipartFile.fromString(
          jsonEncode(roomData),
          contentType: MediaType('application', 'json'),
        ),
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      final response = await _dio.post(
        ApiEndpoints.rooms,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Room.fromJson(response.data);
      }
      throw Exception('Failed to create room');
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }


  Future<Room> updateRoomWithImage(int id, Map<String, dynamic> roomData, File? imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'roomData': MultipartFile.fromString(
          jsonEncode(roomData),
          contentType: MediaType('application', 'json'),
        ),
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      final response = await _dio.put(
        '${ApiEndpoints.rooms}/$id',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Room.fromJson(response.data);
      }
      throw Exception('Failed to update room');
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }
}