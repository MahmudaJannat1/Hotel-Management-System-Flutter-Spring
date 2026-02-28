import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/settings_model.dart';
import 'package:hotel_management_app/data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();

  HotelSettings? _hotelSettings;
  SystemSettings? _systemSettings;
  NotificationSettings? _notificationSettings;
  List<Map<String, dynamic>> _systemLogs = [];
  bool _isLoading = false;
  String? _error;
  String? _lastBackupUrl;

  HotelSettings? get hotelSettings => _hotelSettings;
  SystemSettings? get systemSettings => _systemSettings;
  NotificationSettings? get notificationSettings => _notificationSettings;
  List<Map<String, dynamic>> get systemLogs => _systemLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastBackupUrl => _lastBackupUrl;

  // ========== Load All Settings ==========

  Future<void> loadAllSettings(int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadHotelSettings(hotelId),
        loadSystemSettings(),
        loadNotificationSettings(hotelId),
      ]);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ========== Hotel Settings ==========

  Future<void> loadHotelSettings(int hotelId) async {
    try {
      _hotelSettings = await _repository.getHotelSettings(hotelId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<bool> updateHotelSettings(int hotelId, Map<String, dynamic> settingsData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _hotelSettings = await _repository.updateHotelSettings(hotelId, settingsData);
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

  // ========== System Settings ==========

  Future<void> loadSystemSettings() async {
    try {
      _systemSettings = await _repository.getSystemSettings();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<bool> updateSystemSettings(Map<String, dynamic> settingsData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _systemSettings = await _repository.updateSystemSettings(settingsData);
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

  // ========== Notification Settings ==========

  Future<void> loadNotificationSettings(int hotelId) async {
    try {
      _notificationSettings = await _repository.getNotificationSettings(hotelId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<bool> updateNotificationSettings(int hotelId, Map<String, bool> settingsData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notificationSettings = await _repository.updateNotificationSettings(hotelId, settingsData);
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

  // ========== Backup & Restore ==========

  Future<bool> createBackup() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastBackupUrl = await _repository.createBackup();
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

  Future<bool> restoreBackup(String backupFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.restoreBackup(backupFile);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ========== System Logs ==========

  Future<void> loadSystemLogs(
      int hotelId, {
        DateTime? startDate,
        DateTime? endDate,
        String? level,
      }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _systemLogs = await _repository.getSystemLogs(
        hotelId,
        startDate: startDate,
        endDate: endDate,
        level: level,
      );
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ========== Helper Methods ==========

  void clearError() {
    _error = null;
    notifyListeners();
  }
}