import 'package:hotel_management_app/data/models/settings_model.dart';
import 'package:hotel_management_app/data/remote/services/settings_api_service.dart';

class SettingsRepository {
  final SettingsApiService _apiService = SettingsApiService();

  // ========== Hotel Settings ==========

  Future<HotelSettings> getHotelSettings(int hotelId) async {
    try {
      return await _apiService.getHotelSettings(hotelId);
    } catch (e) {
      throw Exception('Failed to load hotel settings: $e');
    }
  }

  Future<HotelSettings> updateHotelSettings(int hotelId, Map<String, dynamic> settingsData) async {
    try {
      return await _apiService.updateHotelSettings(hotelId, settingsData);
    } catch (e) {
      throw Exception('Failed to update hotel settings: $e');
    }
  }

  // ========== System Settings ==========

  Future<SystemSettings> getSystemSettings() async {
    try {
      return await _apiService.getSystemSettings();
    } catch (e) {
      throw Exception('Failed to load system settings: $e');
    }
  }

  Future<SystemSettings> updateSystemSettings(Map<String, dynamic> settingsData) async {
    try {
      return await _apiService.updateSystemSettings(settingsData);
    } catch (e) {
      throw Exception('Failed to update system settings: $e');
    }
  }

  // ========== Notification Settings ==========

  Future<NotificationSettings> getNotificationSettings(int hotelId) async {
    try {
      return await _apiService.getNotificationSettings(hotelId);
    } catch (e) {
      throw Exception('Failed to load notification settings: $e');
    }
  }

  Future<NotificationSettings> updateNotificationSettings(
      int hotelId,
      Map<String, bool> settingsData,
      ) async {
    try {
      return await _apiService.updateNotificationSettings(hotelId, settingsData);
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }

  // ========== Backup & Restore ==========

  Future<String> createBackup() async {
    try {
      return await _apiService.createBackup();
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  Future<bool> restoreBackup(String backupFile) async {
    try {
      return await _apiService.restoreBackup(backupFile);
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
      return await _apiService.getSystemLogs(
        hotelId,
        startDate: startDate,
        endDate: endDate,
        level: level,
      );
    } catch (e) {
      throw Exception('Failed to load system logs: $e');
    }
  }
}