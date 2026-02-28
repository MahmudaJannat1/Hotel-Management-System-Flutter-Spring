import 'package:hotel_management_app/data/remote/services/admin_api_service.dart';

class DashboardRepository {
  final AdminApiService _apiService = AdminApiService();

  Future<Map<String, dynamic>> getDashboardSummary() async {
    // ❌ Mock data সরিয়ে ফেলুন
    // return await _apiService.getDashboardSummary(); // সরাসরি API call

    try {
      return await _apiService.getDashboardSummary();
    } catch (e) {
      // Error টা provider এ handle হবে
      rethrow;
    }
  }
}



// import 'package:hotel_management_app/data/remote/services/admin_api_service.dart';
//
// class DashboardRepository {
//   final AdminApiService _apiService = AdminApiService();
//
//   Future<Map<String, dynamic>> getDashboardSummary() async {
//     try {
//       return await _apiService.getDashboardSummary();
//     } catch (e) {
//       // Return mock data for now
//       return {
//         'todayRevenue': 45000.0,
//         'occupancyRate': 72.5,
//         'todayCheckIns': 12,
//         'todayCheckOuts': 8,
//       };
//     }
//   }
// }