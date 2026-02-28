import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/guest_model.dart';

class GuestApiService {
  final Dio _dio = ApiClient().dio;

  Future<List<Guest>> getAllGuests() async {
    try {
      final response = await _dio.get(ApiEndpoints.guests);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Guest.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load guests: $e');
    }
  }

  Future<Guest> getGuestById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.guests}/$id');

      if (response.statusCode == 200) {
        return Guest.fromJson(response.data);
      }
      throw Exception('Guest not found');
    } catch (e) {
      throw Exception('Failed to load guest: $e');
    }
  }

  Future<List<Guest>> searchGuests(String query) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.guests}/search',
        queryParameters: {'name': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Guest.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search guests: $e');
    }
  }
}