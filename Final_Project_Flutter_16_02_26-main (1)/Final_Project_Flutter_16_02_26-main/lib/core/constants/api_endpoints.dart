import 'app_constants.dart';

class ApiEndpoints {
  static const String baseUrl = AppConstants.baseUrl;

  // Auth endpoints
  static const String adminLogin = '/api/admin/auth/login';
  static const String adminLogout = '/api/admin/auth/logout';

  // Mobile endpoints
  static const String mobileLogin = '/api/mobile/auth/login';
  static const String mobileLogout = '/api/mobile/auth/logout';
  static const String initialSync = '/api/mobile/sync/initial';
  static const String pushUpdates = '/api/mobile/sync/push';
  static const String syncStatus = '/api/mobile/sync/status';

  // Admin endpoints
  static const String users = '/api/admin/users';
  static const String hotels = '/api/admin/hotels';
  static const String rooms = '/api/admin/rooms';
  static const String bookings = '/api/admin/bookings';
  static const String guests = '/api/admin/guests';
  static const String inventory = '/api/admin/inventory';
  static const String hr = '/api/admin/hr';
  static const String reports = '/api/admin/reports';
  static const String payments = '/api/admin/payments';
  static const String settings = '/api/admin/settings';
  static const String dashboard = '/api/admin/dashboard/summary';
}