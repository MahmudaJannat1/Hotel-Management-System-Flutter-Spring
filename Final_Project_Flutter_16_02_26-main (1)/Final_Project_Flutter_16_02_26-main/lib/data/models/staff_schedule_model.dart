import 'dart:ui';

import 'package:flutter/material.dart';

class StaffSchedule {
  final int id;
  final int staffId;
  final String staffName;
  final DateTime workDate;
  final String shift; // Morning, Evening, Night
  final String startTime;
  final String endTime;
  final String? notes;

  StaffSchedule({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.workDate,
    required this.shift,
    required this.startTime,
    required this.endTime,
    this.notes,
  });


  Map<String, dynamic> toMap() {
    final map = {
      'staffId': staffId,
      'staffName': staffName,
      'workDate': workDate.toIso8601String().split('T')[0],
      'shift': shift,
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes,
    };
    if (id > 0) {
      map['id'] = id;
    }
    return map;
  }

  factory StaffSchedule.fromMap(Map<String, dynamic> map) {
    return StaffSchedule(
      id: map['id'] ?? 0,
      staffId: map['staffId'] ?? 0,
      staffName: map['staffName'] ?? '',
      workDate: DateTime.parse(map['workDate']),
      shift: map['shift'] ?? 'Morning',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      notes: map['notes'],
    );
  }

  String get shiftTime => '$startTime - $endTime';

  Color get shiftColor {
    switch (shift) {
      case 'Morning':
        return Colors.orange;
      case 'Evening':
        return Colors.blue;
      case 'Night':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}