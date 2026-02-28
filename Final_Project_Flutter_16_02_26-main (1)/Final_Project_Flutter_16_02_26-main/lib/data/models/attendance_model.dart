import 'package:flutter/material.dart';

class Attendance {
  final int id;
  final int employeeId;
  final String employeeName;
  final String? employeeIdNumber;
  final String? department;
  final DateTime date;
  final TimeOfDay? checkInTime;
  final TimeOfDay? checkOutTime;
  final String status;
  final double? workingHours;
  final double? overtimeHours;
  final String? remarks;
  final String? markedBy;
  final DateTime? markedAt;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    this.employeeIdNumber,
    this.department,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.workingHours,
    this.overtimeHours,
    this.remarks,
    this.markedBy,
    this.markedAt,
    required this.isApproved,
    this.approvedBy,
    this.approvedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'] ?? '',
      employeeIdNumber: json['employeeIdNumber'],
      department: json['department'],
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      checkInTime: json['checkInTime'] != null
          ? _parseTime(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? _parseTime(json['checkOutTime'])
          : null,
      status: json['status'] ?? 'ABSENT',
      workingHours: json['workingHours']?.toDouble(),
      overtimeHours: json['overtimeHours']?.toDouble(),
      remarks: json['remarks'],
      markedBy: json['markedBy'],
      markedAt: json['markedAt'] != null
          ? DateTime.parse(json['markedAt'])
          : null,
      isApproved: json['isApproved'] ?? false,
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
    );
  }

  static TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}