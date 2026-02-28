import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotel_management_app/core/constants/app_constants.dart';
import 'package:hotel_management_app/data/models/user_model.dart';

class SharedPrefsHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> setToken(String token) async {
    print('Saving token: $token');  // ✅ এই line যোগ করুন
    await _prefs.setString(AppConstants.prefToken, token);
    print('✅ Token saved: ${getToken()}');  // ✅ যোগ করুন
  }

  static String? getToken() {
    return _prefs.getString(AppConstants.prefToken);
  }

  // User
  static Future<void> saveUser(User user) async {
    await _prefs.setInt(AppConstants.prefUserId, user.id);
    await _prefs.setString(AppConstants.prefUserRole, user.role);
    await _prefs.setString(AppConstants.prefUserEmail, user.email);
    await _prefs.setString(AppConstants.prefUserName, user.fullName);
    await _prefs.setBool(AppConstants.prefIsLoggedIn, true);
    if (user.token != null) {
      await setToken(user.token!);
    }
  }

  static int? getUserId() {
    return _prefs.getInt(AppConstants.prefUserId);
  }

  static String? getUserRole() {
    return _prefs.getString(AppConstants.prefUserRole);
  }

  static String? getUserName() {
    return _prefs.getString(AppConstants.prefUserName);
  }

  static bool isLoggedIn() {
    return _prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  }

  // Logout
  static Future<void> clearUserData() async {
    await _prefs.remove(AppConstants.prefToken);
    await _prefs.remove(AppConstants.prefUserId);
    await _prefs.remove(AppConstants.prefUserRole);
    await _prefs.remove(AppConstants.prefUserEmail);
    await _prefs.remove(AppConstants.prefUserName);
    await _prefs.setBool(AppConstants.prefIsLoggedIn, false);
  }

  // Last sync time
  static Future<void> setLastSyncTime(int timestamp) async {
    await _prefs.setInt(AppConstants.prefLastSyncTime, timestamp);
  }

  static int? getLastSyncTime() {
    return _prefs.getInt(AppConstants.prefLastSyncTime);
  }
}