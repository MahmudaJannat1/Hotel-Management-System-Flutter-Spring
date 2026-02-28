// lib/data/models/staff_leave_model.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StaffLeave {
  final int id;
  final int staffId;
  final String staffName;
  final String leaveType; // Sick, Casual, Annual, Emergency
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String status; // Pending, Approved, Rejected, Cancelled
  final String? appliedOn;
  final String? approvedBy;
  final DateTime? approvedDate;
  final String? rejectionReason;
  final String? documents;

  StaffLeave({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    this.appliedOn,
    this.approvedBy,
    this.approvedDate,
    this.rejectionReason,
    this.documents,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'staffId': staffId,
      'staffName': staffName,
      'leaveType': leaveType,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'totalDays': totalDays,
      'reason': reason,
      'status': status,
      'appliedOn': appliedOn ?? DateTime.now().toIso8601String(),
      'approvedBy': approvedBy,
      'approvedDate': approvedDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'documents': documents,
    };
    if (id > 0) {
      map['id'] = id;
    }
    return map;
  }

  factory StaffLeave.fromMap(Map<String, dynamic> map) {
    return StaffLeave(
      id: map['id'] ?? 0,
      staffId: map['staffId'] ?? 0,
      staffName: map['staffName'] ?? '',
      leaveType: map['leaveType'] ?? 'Sick',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      totalDays: map['totalDays'] ?? 0,
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'Pending',
      appliedOn: map['appliedOn'], // Keep as String
      approvedBy: map['approvedBy'],
      approvedDate: map['approvedDate'] != null ? DateTime.parse(map['approvedDate']) : null,
      rejectionReason: map['rejectionReason'],
      documents: map['documents'],
    );
  }

  Color get statusColor {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help;
    }
  }
}