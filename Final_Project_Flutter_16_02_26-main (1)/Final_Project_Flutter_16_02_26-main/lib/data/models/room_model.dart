import 'dart:convert';

import 'package:flutter/material.dart';

class Room {
  final int id;
  final String roomNumber;
  final String roomType;
  final String floor;
  final double price;
  final int maxOccupancy;
  final String status; // AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED
  final String description;
  final List<String> amenities;
  final List<String> images;
  final int? hotelId;

  Room({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.floor,
    required this.price,
    required this.maxOccupancy,
    required this.status,
    required this.description,
    required this.amenities,
    required this.images,
    this.hotelId,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      roomNumber: json['roomNumber'] ?? '',
      roomType: json['roomTypeName'] ?? json['roomType'] ?? 'Standard',
      floor: json['floor'] ?? '1',
      price: (json['basePrice'] ?? 0).toDouble(),
      maxOccupancy: json['maxOccupancy'] ?? 2,
      status: json['status'] ?? 'AVAILABLE',
      description: json['description'] ?? '',
      amenities: _parseList(json['amenities']),
      // 🔥 FIX THIS:
      images: _parseImages(json['images']),  // New method
      hotelId: json['hotelId'],
    );
  }
  static List<String> _parseImages(dynamic value) {
    if (value == null) return [];

    print('📸 Raw images value: $value');  // Debug

    // Case 1: It's already a List
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    // Case 2: It's a String (single image path)
    if (value is String) {
      // Check if it's a JSON array string
      if (value.startsWith('[') && value.endsWith(']')) {
        try {
          final List<dynamic> list = jsonDecode(value);
          return list.map((e) => e.toString()).toList();
        } catch (e) {
          print('Error parsing JSON array: $e');
        }
      }

      // Single image path - return as list with one item
      if (value.isNotEmpty) {
        return [value];  // 🔥 Convert single string to List
      }
    }

    return [];
  }
  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      try {
        final List<dynamic> list = List.from(jsonDecode(value));
        return list.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'roomType': roomType,
      'floor': floor,
      'basePrice': price,
      'maxOccupancy': maxOccupancy,
      'status': status,
      'description': description,
      'amenities': amenities,
      'images': images,
      'hotelId': hotelId,
    };
  }

  String get firstImageUrl {
    if (images.isEmpty) return '';

    String imagePath = images.first;
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else if (imagePath.startsWith('/api')) {
      return 'http://192.168.0.103:8080$imagePath';
      //'http://192.168.20.50:8080${room.images.first}',

    } else {
      return imagePath;  // asset path
    }
  }

  bool get hasNetworkImage {
    return images.isNotEmpty &&
        (images.first.startsWith('http') || images.first.startsWith('/api'));
  }

  bool get isAvailable => status == 'AVAILABLE';
  bool get isOccupied => status == 'OCCUPIED';
  bool get isMaintenance => status == 'MAINTENANCE';
  bool get isReserved => status == 'RESERVED';


  Color get statusColor {
    switch (status) {
      case 'AVAILABLE': return Colors.green;
      case 'OCCUPIED': return Colors.orange;
      case 'MAINTENANCE': return Colors.red;
      case 'RESERVED': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'AVAILABLE': return 'Available';
      case 'OCCUPIED': return 'Occupied';
      case 'MAINTENANCE': return 'Maintenance';
      case 'RESERVED': return 'Reserved';
      default: return status;
    }
  }
}