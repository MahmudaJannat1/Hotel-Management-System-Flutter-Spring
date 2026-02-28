import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  Map<String, dynamic>? _dashboardData;
  List<Map<String, dynamic>> _recentActivities = []; // ✅ New field
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<Map<String, dynamic>> get recentActivities => _recentActivities; // ✅ Getter
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getDashboardSummary();
      _dashboardData = data;
      _recentActivities = data['recentActivities'] ?? []; // ✅ Extract activities
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }
}