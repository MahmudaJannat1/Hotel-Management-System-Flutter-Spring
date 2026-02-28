import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/auth_models.dart';
import 'package:hotel_management_app/data/models/user_model.dart';

import '../../local/preferences/shared_prefs_helper.dart';

class AuthApiService {
  final Dio _dio = ApiClient().dio;

  Future<User> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);

      final response = await _dio.post(
        ApiEndpoints.adminLogin,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        print('Login Response Token: ${loginResponse.token}');
        await SharedPrefsHelper.setToken(loginResponse.token);  // ✅ Force save
        print('✅ Token after save: ${SharedPrefsHelper.getToken()}');  // ✅ Verify

        return User(
          id: loginResponse.userId,
          username: loginResponse.username,
          email: loginResponse.email,
          firstName: '', // Will be updated from user profile
          lastName: '',  // Will be updated from user profile
          role: loginResponse.role,
          isActive: true,
        );
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid username or password');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.adminLogout);
    } catch (e) {
      print('Logout error: $e');
    }
  }
}