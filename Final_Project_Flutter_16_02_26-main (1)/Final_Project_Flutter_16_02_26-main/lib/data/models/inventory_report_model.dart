class InventoryReport {
  final String reportType;
  final DateTime asOfDate;
  final String generatedAt;

  // Summary
  final int totalItems;
  final int lowStockItems;
  final int outOfStockItems;
  final double totalInventoryValue;

  // Category wise
  final Map<String, CategoryInventory> categoryStats;

  // Low stock items
  final List<LowStockItem> lowStockItemsList;

  // Recent transactions
  final List<InventoryTransaction> recentTransactions;

  InventoryReport({
    required this.reportType,
    required this.asOfDate,
    required this.generatedAt,
    required this.totalItems,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.totalInventoryValue,
    required this.categoryStats,
    required this.lowStockItemsList,
    required this.recentTransactions,
  });

  factory InventoryReport.fromJson(Map<String, dynamic> json) {
    return InventoryReport(
      reportType: json['reportType'] ?? 'INVENTORY_REPORT',
      asOfDate: DateTime.parse(json['asOfDate'] ?? DateTime.now().toIso8601String()),
      generatedAt: json['generatedAt'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      lowStockItems: json['lowStockItems'] ?? 0,
      outOfStockItems: json['outOfStockItems'] ?? 0,
      totalInventoryValue: (json['totalInventoryValue'] ?? 0).toDouble(),
      categoryStats: (json['categoryStats'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, CategoryInventory.fromJson(value))),
      lowStockItemsList: (json['lowStockItemsList'] as List? ?? [])
          .map((i) => LowStockItem.fromJson(i))
          .toList(),
      recentTransactions: (json['recentTransactions'] as List? ?? [])
          .map((t) => InventoryTransaction.fromJson(t))
          .toList(),
    );
  }
}

class CategoryInventory {
  final String category;
  final int itemCount;
  final int totalQuantity;
  final double totalValue;
  final int lowStockCount;

  CategoryInventory({
    required this.category,
    required this.itemCount,
    required this.totalQuantity,
    required this.totalValue,
    required this.lowStockCount,
  });

  factory CategoryInventory.fromJson(Map<String, dynamic> json) {
    return CategoryInventory(
      category: json['category'] ?? '',
      itemCount: json['itemCount'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      lowStockCount: json['lowStockCount'] ?? 0,
    );
  }
}

class LowStockItem {
  final int itemId;
  final String itemName;
  final String category;
  final int currentQuantity;
  final int reorderLevel;
  final String unit;
  final String? supplier;
  final String status;

  LowStockItem({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.currentQuantity,
    required this.reorderLevel,
    required this.unit,
    this.supplier,
    required this.status,
  });

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      category: json['category'] ?? '',
      currentQuantity: json['currentQuantity'] ?? 0,
      reorderLevel: json['reorderLevel'] ?? 0,
      unit: json['unit'] ?? 'pcs',
      supplier: json['supplier'],
      status: json['status'] ?? 'LOW_STOCK',
    );
  }
}

class InventoryTransaction {
  final DateTime date;
  final String itemName;
  final String transactionType;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? supplier;

  InventoryTransaction({
    required this.date,
    required this.itemName,
    required this.transactionType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.supplier,
  });

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      itemName: json['itemName'] ?? '',
      transactionType: json['transactionType'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      supplier: json['supplier'],
    );
  }
}