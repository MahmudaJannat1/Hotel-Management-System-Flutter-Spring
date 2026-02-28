import 'package:hotel_management_app/data/models/user_model.dart';
import 'package:hotel_management_app/data/remote/services/auth_api_service.dart';
import 'package:hotel_management_app/data/local/preferences/shared_prefs_helper.dart';

class AuthRepository {
  final AuthApiService _apiService = AuthApiService();

  Future<User> login(String username, String password) async {
    try {
      final user = await _apiService.login(username, password);

      // Save user data locally
      await SharedPrefsHelper.saveUser(user);

      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } finally {
      await SharedPrefsHelper.clearUserData();
    }
  }

  bool isLoggedIn() {
    return SharedPrefsHelper.isLoggedIn();
  }

  User? getCurrentUser() {
    final userId = SharedPrefsHelper.getUserId();
    final role = SharedPrefsHelper.getUserRole();
    final name = SharedPrefsHelper.getUserName();

    if (userId == null || role == null) return null;

    return User(
      id: userId,
      username: '',
      email: '',
      firstName: name?.split(' ').first ?? '',
      lastName: name?.split(' ').last ?? '',
      role: role,
      isActive: true,
    );
  }
}