import 'package:hotel_management_app/data/models/inventory_model.dart';
import 'package:hotel_management_app/data/remote/services/inventory_api_service.dart';
import 'package:hotel_management_app/data/local/database/daos/inventory_dao.dart';

class InventoryRepository {
  final InventoryApiService _apiService = InventoryApiService();
  final InventoryDao _inventoryDao = InventoryDao();

  // ========== API Methods ==========

  Future<List<InventoryItem>> getAllItems(int hotelId) async {
    try {
      return await _apiService.getAllItems(hotelId);
    } catch (e) {
      throw Exception('Failed to load inventory: $e');
    }
  }

  Future<InventoryItem> getItemById(int id) async {
    try {
      return await _apiService.getItemById(id);
    } catch (e) {
      throw Exception('Failed to load item: $e');
    }
  }

  Future<List<InventoryItem>> getItemsByCategory(int hotelId, String category) async {
    try {
      return await _apiService.getItemsByCategory(hotelId, category);
    } catch (e) {
      throw Exception('Failed to load items by category: $e');
    }
  }

  Future<List<InventoryItem>> getLowStockItems(int hotelId) async {
    try {
      return await _apiService.getLowStockItems(hotelId);
    } catch (e) {
      throw Exception('Failed to load low stock items: $e');
    }
  }

  Future<List<InventoryItem>> getExpiringItems(int hotelId, int days) async {
    try {
      return await _apiService.getExpiringItems(hotelId, days);
    } catch (e) {
      throw Exception('Failed to load expiring items: $e');
    }
  }

  Future<InventoryItem> createItem(Map<String, dynamic> itemData) async {
    try {
      return await _apiService.createItem(itemData);
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  Future<InventoryItem> updateItem(int id, Map<String, dynamic> itemData) async {
    try {
      return await _apiService.updateItem(id, itemData);
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  Future<InventoryItem> adjustStock(int id, int newQuantity, String reason) async {
    try {
      return await _apiService.adjustStock(id, newQuantity, reason);
    } catch (e) {
      throw Exception('Failed to adjust stock: $e');
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _apiService.deleteItem(id);
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // ========== Local DB Methods ==========

  Future<void> syncItems(List<InventoryItem> items) async {
    try {
      await _inventoryDao.deleteAll();
      for (var item in items) {
        await _inventoryDao.insert(item);
      }
    } catch (e) {
      throw Exception('Failed to sync items: $e');
    }
  }

  Future<List<InventoryItem>> getLocalItems() async {
    try {
      return await _inventoryDao.getAllItems();
    } catch (e) {
      throw Exception('Failed to load local items: $e');
    }
  }

  Future<List<InventoryItem>> getLocalLowStockItems() async {
    try {
      return await _inventoryDao.getLowStockItems();
    } catch (e) {
      throw Exception('Failed to load local low stock items: $e');
    }
  }
}