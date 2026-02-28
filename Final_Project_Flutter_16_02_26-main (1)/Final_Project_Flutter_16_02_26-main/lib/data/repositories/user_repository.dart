import 'package:hotel_management_app/data/models/guest_user_model.dart';
import 'package:hotel_management_app/data/models/user_model.dart';
import 'package:hotel_management_app/data/remote/services/user_api_service.dart';
import 'package:hotel_management_app/data/local/database/daos/user_dao.dart';

class UserRepository {
  final UserApiService _apiService = UserApiService();
  final UserDao _userDao = UserDao();

  // For Admin - get from API
  Future<List<User>> getAllUsersFromApi() async {
    return await _apiService.getAllUsers();
  }

  Future<User> getUserById(int id) async {
    return await _apiService.getUserById(id);
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    return await _apiService.createUser(userData);
  }

  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    return await _apiService.updateUser(id, userData);
  }

  Future<void> deleteUser(int id) async {
    await _apiService.deleteUser(id);
  }

  Future<void> toggleUserStatus(int id) async {
    await _apiService.toggleUserStatus(id);
  }

  Future<List<User>> getUsersByRole(String role) async {
    return await _apiService.getUsersByRole(role);
  }

  // For local DB (sync)
  Future<void> syncUsers(List<User> users) async {
    await _userDao.deleteAll();
    for (var user in users) {
      await _userDao.insert(user as GuestUser);
    }
  }

  Future<List<User>> getLocalUsers() async {
    return await _userDao.getAllUsers();
  }
}