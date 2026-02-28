import 'package:sqflite/sqflite.dart';
import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:hotel_management_app/data/models/inventory_model.dart';

class InventoryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(InventoryItem item) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'inventory',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAll(List<InventoryItem> items) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var item in items) {
      batch.insert(
        'inventory',
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<InventoryItem>> getAllItems() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      orderBy: 'category, itemName',
    );

    return List.generate(maps.length, (i) {
      return InventoryItem.fromJson(maps[i]);
    });
  }

  Future<InventoryItem?> getItemById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return InventoryItem.fromJson(maps.first);
    }
    return null;
  }

  Future<List<InventoryItem>> getItemsByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'itemName',
    );

    return List.generate(maps.length, (i) {
      return InventoryItem.fromJson(maps[i]);
    });
  }

  Future<List<InventoryItem>> getLowStockItems() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('inventory');

    return maps
        .map((map) => InventoryItem.fromJson(map))
        .where((item) => item.quantity <= item.reorderLevel)
        .toList();
  }

  Future<List<InventoryItem>> getExpiringItems(int days) async {
    final expiryDate = DateTime.now().add(Duration(days: days));
    final expiryStr = expiryDate.toIso8601String().split('T')[0];

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: 'expiryDate <= ? AND expiryDate IS NOT NULL',
      whereArgs: [expiryStr],
    );

    return List.generate(maps.length, (i) {
      return InventoryItem.fromJson(maps[i]);
    });
  }

  Future<int> update(InventoryItem item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'inventory',
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> updateQuantity(int id, int newQuantity) async {
    final db = await _dbHelper.database;
    return await db.update(
      'inventory',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('inventory');
  }

  Future<int> count() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM inventory');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalValue() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
        'SELECT SUM(quantity * unitPrice) as total FROM inventory'
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}