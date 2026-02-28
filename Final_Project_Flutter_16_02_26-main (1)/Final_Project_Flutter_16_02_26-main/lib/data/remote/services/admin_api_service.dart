import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';

class AdminApiService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await _dio.get(ApiEndpoints.dashboard);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Dashboard endpoint not found (404) - Check backend URL');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout - Backend not running?');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to backend - Check IP address');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}



// import 'package:dio/dio.dart';
// import 'package:hotel_management_app/data/remote/client/api_client.dart';
// import 'package:hotel_management_app/core/constants/api_endpoints.dart';
//
// class AdminApiService {
//   final Dio _dio = ApiClient().dio;
//
//   Future<Map<String, dynamic>> getDashboardSummary() async {
//     try {
//       final response = await _dio.get(ApiEndpoints.dashboard);
//
//       if (response.statusCode == 200) {
//         return response.data;
//       }
//       throw Exception('Failed to load dashboard');
//     } catch (e) {
//       // Return mock data for development
//       return {
//         'todayRevenue': 45000.0,
//         'weekRevenue': 315000.0,
//         'monthRevenue': 1350000.0,
//         'occupancyRate': 72.5,
//         'todayCheckIns': 12,
//         'todayCheckOuts': 8,
//         'totalRooms': 50,
//         'occupiedRooms': 36,
//         'availableRooms': 12,
//         'maintenanceRooms': 2,
//       };
//     }
//   }
// }