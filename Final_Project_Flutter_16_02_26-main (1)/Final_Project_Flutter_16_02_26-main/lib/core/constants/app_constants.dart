class AppConstants {
  static const String appName = 'Hotel Management';
  // static const String baseUrl = 'http://10.0.2.2:8080'; // Android emulator
  // static const String baseUrl = 'http://localhost:8080'; // iOS simulator
  //static const String baseUrl = 'http://192.168.20.50:8080'; // Real device
  static const String baseUrl = 'http://192.168.0.103:8080'; // Real device

  // Shared Preferences Keys
  static const String prefToken = 'auth_token';
  static const String prefUserId = 'user_id';
  static const String prefUserRole = 'user_role';
  static const String prefUserEmail = 'user_email';
  static const String prefUserName = 'user_name';
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefLastSyncTime = 'last_sync_time';

  // Database
  static const String dbName = 'hotel_management.db';
  static const int dbVersion = 2;
}