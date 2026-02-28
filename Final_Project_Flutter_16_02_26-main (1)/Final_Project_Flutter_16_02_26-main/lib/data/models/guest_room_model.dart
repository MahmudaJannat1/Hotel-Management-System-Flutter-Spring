import 'dart:convert';

class GuestRoom {
  final int id;
  final String roomNumber;
  final String roomType;
  final String floor;
  final double price;
  final int maxOccupancy;
  final bool isAvailable;
  final String description;
  final List<String> amenities;
  final List<String> images;
  final int? hotelId;

  GuestRoom({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.floor,
    required this.price,
    required this.maxOccupancy,
    required this.isAvailable,
    required this.description,
    required this.amenities,
    required this.images,
    this.hotelId,
  });

  factory GuestRoom.fromJson(Map<String, dynamic> json) {
    return GuestRoom(
      id: json['id'] ?? 0,
      roomNumber: json['roomNumber'] ?? '',
      roomType: json['roomTypeName'] ?? json['roomType'] ?? 'Standard',
      floor: json['floor'] ?? '1',
      price: (json['basePrice'] ?? 0).toDouble(),
      maxOccupancy: json['maxOccupancy'] ?? 2,
      isAvailable: json['status'] == 'AVAILABLE',
      description: json['description'] ?? '',
      amenities: _parseList(json['amenities']),
      images: _parseImageList(json['images']),
      hotelId: json['hotelId'],
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      // কমা সেপারেটেড স্ট্রিং
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<String> _parseImageList(dynamic value) {
    if (value == null) return [];

    print('Raw image value: $value (${value.runtimeType})'); // ডিবাগ

    // যদি JSON array string হয়
    if (value is String) {
      try {
        // যদি ইতিমধ্যে JSON array format এ থাকে
        if (value.startsWith('[') && value.endsWith(']')) {
          final List<dynamic> list = jsonDecode(value);
          final result = list.map((e) => e.toString()).toList();
          print('Parsed JSON array: $result');
          return result;
        }
        // কমা সেপারেটেড string হলে
        else if (value.contains(',')) {
          final result = value.split(',').map((e) => e.trim()).toList();
          print('Parsed comma separated: $result');
          return result;
        }
        // একক ইমেজ পাথ হলে
        else {
          print('Single image path: [$value]');
          return [value];
        }
      } catch (e) {
        print('Error parsing images: $e');
        // JSON পার্স করতে ব্যর্থ হলে, কমা সেপারেটেড হিসেবে চেষ্টা
        if (value.contains(',')) {
          return value.split(',').map((e) => e.trim()).toList();
        }
        return [];
      }
    }

    // যদি ইতিমধ্যে List হয়
    if (value is List) {
      final result = value.map((e) => e.toString()).toList();
      print('Already a list: $result');
      return result;
    }

    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'roomType': roomType,
      'floor': floor,
      'price': price,
      'maxOccupancy': maxOccupancy,
      'isAvailable': isAvailable ? 1 : 0,
      'description': description,
      'amenities': amenities.join(','),
      'images': jsonEncode(images), // JSON array হিসেবে সংরক্ষণ
      'hotelId': hotelId,
    };
  }

  factory GuestRoom.fromMap(Map<String, dynamic> map) {
    print('Building GuestRoom from map: ${map['roomNumber']}'); // ডিবাগ

    return GuestRoom(
      id: map['id'] ?? 0,
      roomNumber: map['roomNumber'] ?? '',
      roomType: map['roomType'] ?? '',
      floor: map['floor'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      maxOccupancy: map['maxOccupancy'] ?? 2,
      isAvailable: map['status'] == 'AVAILABLE',
      description: map['description'] ?? '',
      amenities: _parseList(map['amenities']),
      images: _parseImageList(map['images']),
      hotelId: map['hotelId'],
    );
  }
}