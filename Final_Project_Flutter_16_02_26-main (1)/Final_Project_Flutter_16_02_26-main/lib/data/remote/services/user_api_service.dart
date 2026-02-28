import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/user_model.dart';

class UserApiService {
  final Dio _dio = ApiClient().dio;

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get(ApiEndpoints.users);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.users}/$id');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('User not found');
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.users,
        data: userData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(response.data);
      }
      throw Exception('Failed to create user');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.users}/$id',
        data: userData,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Failed to update user');
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.users}/$id');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<void> toggleUserStatus(int id) async {
    try {
      await _dio.patch('${ApiEndpoints.users}/$id/status');
    } catch (e) {
      throw Exception('Failed to toggle user status: $e');
    }
  }

  Future<List<User>> getUsersByRole(String role) async {
    try {
      final response = await _dio.get('${ApiEndpoints.users}/role/$role');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load users by role: $e');
    }
  }
}