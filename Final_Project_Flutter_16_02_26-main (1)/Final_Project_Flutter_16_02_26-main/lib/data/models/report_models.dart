import 'package:flutter/cupertino.dart';

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});

  String get startDateStr => startDate.toIso8601String().split('T')[0];
  String get endDateStr => endDate.toIso8601String().split('T')[0];
}

class ReportSummary {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  ReportSummary({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}