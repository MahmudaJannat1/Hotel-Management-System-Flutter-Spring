import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/user_model.dart';
import 'package:hotel_management_app/data/repositories/auth_repository.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/services/navigation_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  String? get userRole => _currentUser?.role;

  AuthProvider() {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    _currentUser = _authRepository.getCurrentUser();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(username, password);
      _isLoading = false;
      notifyListeners();

      // Navigate based on role
      _navigateToHome();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.logout();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();

    NavigationService.pushReplacementNamed(AppRoutes.login);
  }

  void _navigateToHome() {
    switch (_currentUser?.role) {
      case 'ADMIN':
        NavigationService.pushReplacementNamed(AppRoutes.adminHome);
        break;
      case 'MANAGER':
        NavigationService.pushReplacementNamed(AppRoutes.managerHome);
        break;
      case 'STAFF':
        NavigationService.pushReplacementNamed(AppRoutes.staffHome);
        break;
      default:
        NavigationService.pushReplacementNamed(AppRoutes.guestHome);
    }
  }
}