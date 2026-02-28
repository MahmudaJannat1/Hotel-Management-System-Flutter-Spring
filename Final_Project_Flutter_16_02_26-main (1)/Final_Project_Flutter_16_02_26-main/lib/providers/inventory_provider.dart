import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/inventory_model.dart';
import 'package:hotel_management_app/data/repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _repository = InventoryRepository();

  List<InventoryItem> _items = [];
  bool _isLoading = false;
  String? _error;
  InventoryItem? _selectedItem;

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  InventoryItem? get selectedItem => _selectedItem;

  // Statistics
  int get totalItems => _items.length;
  int get lowStockItems => _items.where((i) => i.status == 'LOW_STOCK').length;
  int get outOfStockItems => _items.where((i) => i.status == 'OUT_OF_STOCK').length;
  int get expiringSoonItems => _items.where((i) => i.status == 'EXPIRING_SOON').length;

  double get totalInventoryValue => _items.fold(0, (sum, i) => sum + i.totalValue);

  Future<void> loadAllItems(int hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getAllItems(hotelId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadItemById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedItem = await _repository.getItemById(id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createItem(Map<String, dynamic> itemData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newItem = await _repository.createItem(itemData);
      _items.add(newItem);
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

  Future<bool> updateItem(int id, Map<String, dynamic> itemData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedItem = await _repository.updateItem(id, itemData);
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        final newList = List<InventoryItem>.from(_items);
        newList[index] = updatedItem;
        _items = newList;
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

  Future<bool> adjustStock(int id, int newQuantity, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedItem = await _repository.adjustStock(id, newQuantity, reason);
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        final newList = List<InventoryItem>.from(_items);
        newList[index] = updatedItem;
        _items = newList;
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

  Future<bool> deleteItem(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteItem(id);
      _items.removeWhere((i) => i.id == id);
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

  List<InventoryItem> getItemsByCategory(String category) {
    return _items.where((i) => i.category == category).toList();
  }

  List<InventoryItem> searchItems(String query) {
    if (query.isEmpty) return _items;
    return _items.where((i) {
      return i.itemName.toLowerCase().contains(query.toLowerCase()) ||
          i.itemCode.toLowerCase().contains(query.toLowerCase()) ||
          (i.category.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  void selectItem(InventoryItem item) {
    _selectedItem = item;
    notifyListeners();
  }

  void clearSelection() {
    _selectedItem = null;
    notifyListeners();
  }
}