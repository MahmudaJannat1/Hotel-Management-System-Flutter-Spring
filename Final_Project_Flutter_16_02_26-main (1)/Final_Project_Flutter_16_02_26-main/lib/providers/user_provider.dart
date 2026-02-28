import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/user_model.dart';
import 'package:hotel_management_app/data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();

  List<User> _users = [];
  bool _isLoading = false;
  String? _error;
  User? _selectedUser;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get selectedUser => _selectedUser;

  Future<void> loadAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _repository.getAllUsersFromApi();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = await _repository.createUser(userData);
      _users.add(newUser);
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

  Future<bool> updateUser(int id, Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _repository.updateUser(id, userData);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
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

  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
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

  Future<bool> toggleUserStatus(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.toggleUserStatus(id);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = User(
          id: _users[index].id,
          username: _users[index].username,
          email: _users[index].email,
          firstName: _users[index].firstName,
          lastName: _users[index].lastName,
          role: _users[index].role,
          phone: _users[index].phone,
          isActive: !_users[index].isActive,
          // hotelId: _users[index].hotelId,
          // createdAt: _users[index].createdAt,
        );
      }
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

  void selectUser(User user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearSelection() {
    _selectedUser = null;
    notifyListeners();
  }

  List<User> getUsersByRole(String role) {
    return _users.where((u) => u.role == role).toList();
  }

  List<User> getActiveUsers() {
    return _users.where((u) => u.isActive).toList();
  }

  List<User> getInactiveUsers() {
    return _users.where((u) => !u.isActive).toList();
  }
}