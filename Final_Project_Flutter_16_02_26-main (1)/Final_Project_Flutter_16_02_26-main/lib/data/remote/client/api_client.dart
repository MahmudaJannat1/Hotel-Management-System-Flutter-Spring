import 'package:dio/dio.dart';
import 'package:hotel_management_app/core/constants/app_constants.dart';
import 'package:hotel_management_app/data/local/preferences/shared_prefs_helper.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 120),  // 🔥 HERE - 2 minutes
      sendTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add token to requests
        final token = SharedPrefsHelper.getToken();
        print('Token from SharedPrefs: $token');  // ✅ এই line টা আছেই
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('REQUEST: ${options.method} ${options.path}');
        print('HEADERS: ${options.headers}');
        print('DATA: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('RESPONSE: ${response.statusCode} ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('ERROR: ${error.message}');
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - logout user
          SharedPrefsHelper.clearUserData();
        }
        return handler.next(error);
      },
    ));
  }
}