import 'dart:ui';

import 'package:flutter/material.dart';

class InventoryItem {
  final int id;
  final String itemName;
  final String itemCode;
  final String category;
  final String? subCategory;
  final String description;
  final int quantity;
  final String unit;
  final double unitPrice;
  final int reorderLevel;
  final int? maximumLevel;
  final String? location;
  final String? supplier;
  final int? supplierId;
  final String? brand;
  final String? imageUrl;
  final DateTime? expiryDate;
  final String? batchNo;
  final bool isActive;
  final int hotelId;
  final DateTime createdAt;

  InventoryItem({
    required this.id,
    required this.itemName,
    required this.itemCode,
    required this.category,
    this.subCategory,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.reorderLevel,
    this.maximumLevel,
    this.location,
    this.supplier,
    this.supplierId,
    this.brand,
    this.imageUrl,
    this.expiryDate,
    this.batchNo,
    required this.isActive,
    required this.hotelId,
    required this.createdAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? 0,
      itemName: json['itemName'] ?? '',
      itemCode: json['itemCode'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'],
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'pcs',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      reorderLevel: json['reorderLevel'] ?? 0,
      maximumLevel: json['maximumLevel'],
      location: json['location'],
      supplier: json['supplier'],
      supplierId: json['supplierId'],
      brand: json['brand'],
      imageUrl: json['imageUrl'],
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      batchNo: json['batchNo'],
      isActive: json['isActive'] ?? true,
      hotelId: json['hotelId'] ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'itemCode': itemCode,
      'category': category,
      'subCategory': subCategory,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'reorderLevel': reorderLevel,
      'maximumLevel': maximumLevel,
      'location': location,
      'supplier': supplier,
      'supplierId': supplierId,
      'brand': brand,
      'imageUrl': imageUrl,
      'expiryDate': expiryDate?.toIso8601String().split('T')[0],
      'batchNo': batchNo,
      'isActive': isActive,
      'hotelId': hotelId,
    };
  }

  double get totalValue => quantity * unitPrice;

  String get status {
    if (quantity <= 0) return 'OUT_OF_STOCK';
    if (quantity <= reorderLevel) return 'LOW_STOCK';
    if (expiryDate != null && expiryDate!.isBefore(DateTime.now().add(Duration(days: 30)))) {
      return 'EXPIRING_SOON';
    }
    return 'NORMAL';
  }

  Color get statusColor {
    switch (status) {
      case 'OUT_OF_STOCK': return Colors.red;
      case 'LOW_STOCK': return Colors.orange;
      case 'EXPIRING_SOON': return Colors.amber;
      default: return Colors.green;
    }
  }
}