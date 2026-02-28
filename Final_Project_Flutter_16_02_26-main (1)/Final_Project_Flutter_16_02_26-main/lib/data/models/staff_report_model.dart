class StaffAttendanceReport {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final String generatedAt;

  // Summary
  final int totalStaff;
  final int averageDailyPresent;
  final int averageDailyAbsent;
  final int averageDailyLeave;
  final double attendancePercentage;

  // Department wise
  final Map<String, DepartmentAttendance> departmentStats;

  // Individual staff
  final List<StaffAttendance> staffAttendance;

  // Daily summary
  final List<DailyAttendance> dailyAttendance;

  StaffAttendanceReport({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.totalStaff,
    required this.averageDailyPresent,
    required this.averageDailyAbsent,
    required this.averageDailyLeave,
    required this.attendancePercentage,
    required this.departmentStats,
    required this.staffAttendance,
    required this.dailyAttendance,
  });

  factory StaffAttendanceReport.fromJson(Map<String, dynamic> json) {
    return StaffAttendanceReport(
      reportType: json['reportType'] ?? 'STAFF_ATTENDANCE',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      generatedAt: json['generatedAt'] ?? '',
      totalStaff: json['totalStaff'] ?? 0,
      averageDailyPresent: json['averageDailyPresent'] ?? 0,
      averageDailyAbsent: json['averageDailyAbsent'] ?? 0,
      averageDailyLeave: json['averageDailyLeave'] ?? 0,
      attendancePercentage: json['attendancePercentage'] != null
          ? (json['attendancePercentage'] is double
          ? json['attendancePercentage']
          : (json['attendancePercentage'] == 'NaN' || json['attendancePercentage'] == null
          ? 0.0
          : double.tryParse(json['attendancePercentage'].toString()) ?? 0.0))
          : 0.0,
      departmentStats: (json['departmentStats'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, DepartmentAttendance.fromJson(value))),
      staffAttendance: (json['staffAttendance'] as List? ?? [])
          .map((s) => StaffAttendance.fromJson(s))
          .toList(),
      dailyAttendance: (json['dailyAttendance'] as List? ?? [])
          .map((d) => DailyAttendance.fromJson(d))
          .toList(),
    );
  }
}

class DepartmentAttendance {
  final String department;
  final int totalStaff;
  final int present;
  final int absent;
  final int onLeave;
  final double attendancePercentage;

  DepartmentAttendance({
    required this.department,
    required this.totalStaff,
    required this.present,
    required this.absent,
    required this.onLeave,
    required this.attendancePercentage,
  });

  factory DepartmentAttendance.fromJson(Map<String, dynamic> json) {
    return DepartmentAttendance(
      department: json['department'] ?? '',
      totalStaff: json['totalStaff'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      onLeave: json['onLeave'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] ?? 0).toDouble(),
    );
  }
}

class StaffAttendance {
  final int employeeId;
  final String employeeName;
  final String department;
  final String position;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final double attendancePercentage;

  StaffAttendance({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.position,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.leaveDays,
    required this.attendancePercentage,
  });

  factory StaffAttendance.fromJson(Map<String, dynamic> json) {
    return StaffAttendance(
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'] ?? '',
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      totalDays: json['totalDays'] ?? 0,
      presentDays: json['presentDays'] ?? 0,
      absentDays: json['absentDays'] ?? 0,
      leaveDays: json['leaveDays'] ?? 0,
      attendancePercentage: json['attendancePercentage'] != null
          ? (json['attendancePercentage'] is double
          ? json['attendancePercentage']
          : double.tryParse(json['attendancePercentage'].toString()) ?? 0.0)
          : 0.0,
    );
  }
}

class DailyAttendance {
  final DateTime date;
  final int present;
  final int absent;
  final int onLeave;
  final int total;

  DailyAttendance({
    required this.date,
    required this.present,
    required this.absent,
    required this.onLeave,
    required this.total,
  });

  factory DailyAttendance.fromJson(Map<String, dynamic> json) {
    return DailyAttendance(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      onLeave: json['onLeave'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}