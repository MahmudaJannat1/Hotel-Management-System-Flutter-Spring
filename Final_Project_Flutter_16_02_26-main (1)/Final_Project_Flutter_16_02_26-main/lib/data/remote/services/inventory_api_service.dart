import 'package:dio/dio.dart';
import 'package:hotel_management_app/data/remote/client/api_client.dart';
import 'package:hotel_management_app/core/constants/api_endpoints.dart';
import 'package:hotel_management_app/data/models/inventory_model.dart';

class InventoryApiService {
  final Dio _dio = ApiClient().dio;

  // ========== GET Methods ==========

  Future<List<InventoryItem>> getAllItems(int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.inventory}/items',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InventoryItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load inventory: $e');
    }
  }


  Future<InventoryItem> getItemById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.inventory}/items/$id');

      if (response.statusCode == 200) {
        return InventoryItem.fromJson(response.data);
      }
      throw Exception('Item not found');
    } catch (e) {
      throw Exception('Failed to load item: $e');
    }
  }

  Future<List<InventoryItem>> getItemsByCategory(int hotelId, String category) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.inventory}/items/category/$category',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InventoryItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load items by category: $e');
    }
  }

  Future<List<InventoryItem>> getLowStockItems(int hotelId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.inventory}/items/low-stock',
        queryParameters: {'hotelId': hotelId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InventoryItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load low stock items: $e');
    }
  }

  Future<List<InventoryItem>> getExpiringItems(int hotelId, int days) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.inventory}/items/expiring',
        queryParameters: {'hotelId': hotelId, 'days': days},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InventoryItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load expiring items: $e');
    }
  }

  // ========== POST Methods ==========

  Future<InventoryItem> createItem(Map<String, dynamic> itemData) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.inventory}/items',
        data: itemData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return InventoryItem.fromJson(response.data);
      }
      throw Exception('Failed to create item');
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  // ========== PUT Methods ==========

  Future<InventoryItem> updateItem(int id, Map<String, dynamic> itemData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.inventory}/items/$id',
        data: itemData,
      );

      if (response.statusCode == 200) {
        return InventoryItem.fromJson(response.data);
      }
      throw Exception('Failed to update item');
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // ========== PATCH Methods ==========

  Future<InventoryItem> adjustStock(int id, int newQuantity, String reason) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.inventory}/items/$id/adjust-stock',
        data: {
          'newQuantity': newQuantity,
          'reason': reason,
        },
      );

      if (response.statusCode == 200) {
        return InventoryItem.fromJson(response.data);
      }
      throw Exception('Failed to adjust stock');
    } catch (e) {
      throw Exception('Failed to adjust stock: $e');
    }
  }

  // ========== DELETE Methods ==========

  Future<void> deleteItem(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.inventory}/items/$id');
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }
}