import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/settings_model.dart';

class SettingsApiService {
  final Dio _dio = ApiClient().dio;

  // ========== Hotel Settings ==========

  Future<HotelSettings> getHotelSettings(int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.settings}/hotel/$hotelId',
      );

      if (response.statusCode == 200) {
        return HotelSettings.fromJson(response.data);
      }
      throw Exception('Failed to load hotel settings');
    } catch (e) {
      throw Exception('Failed to load hotel settings: $e');
    }
  }

  Future<HotelSettings> updateHotelSettings(int hotelId, Map<String, dynamic> settingsData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.settings}/hotel/$hotelId',
        data: settingsData,
      );

      if (response.statusCode == 200) {
        return HotelSettings.fromJson(response.data);
      }
      throw Exception('Failed to update hotel settings');
    } catch (e) {
      throw Exception('Failed to update hotel settings: $e');
    }
  }

  // ========== System Settings ==========

  Future<SystemSettings> getSystemSettings() async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.settings}/system',
      );

      if (response.statusCode == 200) {
        return SystemSettings.fromJson(response.data);
      }
      throw Exception('Failed to load system settings');
    } catch (e) {
      throw Exception('Failed to load system settings: $e');
    }
  }

  Future<SystemSettings> updateSystemSettings(Map<String, dynamic> settingsData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.settings}/system',
        data: settingsData,
      );

      if (response.statusCode == 200) {
        return SystemSettings.fromJson(response.data);
      }
      throw Exception('Failed to update system settings');
    } catch (e) {
      throw Exception('Failed to update system settings: $e');
    }
  }

  // ========== Notification Settings ==========

  Future<NotificationSettings> getNotificationSettings(int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.settings}/notifications/$hotelId',
      );

      if (response.statusCode == 200) {
        return NotificationSettings.fromJson(response.data);
      }
      throw Exception('Failed to load notification settings');
    } catch (e) {
      throw Exception('Failed to load notification settings: $e');
    }
  }

  Future<NotificationSettings> updateNotificationSettings(
      int hotelId,
      Map<String, bool> settingsData,
      ) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.settings}/notifications/$hotelId',
        data: settingsData,
      );

      if (response.statusCode == 200) {
        return NotificationSettings.fromJson(response.data);
      }
      throw Exception('Failed to update notification settings');
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }

  // ========== Backup & Restore ==========

  Future<String> createBackup() async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.settings}/backup',
      );

      if (response.statusCode == 200) {
        return response.data['backupUrl'] ?? '';
      }
      throw Exception('Failed to create backup');
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  Future<bool> restoreBackup(String backupFile) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.settings}/restore',
        data: {'backupFile': backupFile},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  // ========== Logs ==========

  Future<List<Map<String, dynamic>>> getSystemLogs(
      int hotelId, {
        DateTime? startDate,
        DateTime? endDate,
        String? level,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'hotelId': hotelId,
        if (startDate != null) 'startDate': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
        if (level != null) 'level': level,
      };

      final response = await _dio.get(
        '${ApiEndpoints.settings}/logs',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load system logs: $e');
    }
  }
}