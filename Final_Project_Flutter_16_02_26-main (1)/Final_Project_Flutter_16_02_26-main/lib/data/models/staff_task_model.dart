// lib/data/models/staff_task_model.dart

import 'package:flutter/material.dart';

class StaffTask {
  final int id;
  final int staffId;
  final String staffName;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime? dueDate;
  final String priority; // High, Medium, Low
  final String status; // Pending, In Progress, Completed
  final String? notes;
  final String? assignedBy; // Who assigned this task

  StaffTask({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.title,
    required this.description,
    required this.assignedDate,
    this.dueDate,
    required this.priority,
    required this.status,
    this.notes,
    this.assignedBy,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'staffId': staffId,
      'staffName': staffName,
      'title': title,
      'description': description,
      'assignedDate': assignedDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'status': status,
      'notes': notes,
      'assignedBy': assignedBy,
    };
    if (id > 0) {
      map['id'] = id;
    }
    return map;
  }

  factory StaffTask.fromMap(Map<String, dynamic> map) {
    return StaffTask(
      id: map['id'] ?? 0,
      staffId: map['staffId'] ?? 0,
      staffName: map['staffName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      assignedDate: DateTime.parse(map['assignedDate']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      priority: map['priority'] ?? 'Medium',
      status: map['status'] ?? 'Pending',
      notes: map['notes'],
      assignedBy: map['assignedBy'],
    );
  }

  Color get priorityColor {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now()) && status != 'Completed';
  }
}