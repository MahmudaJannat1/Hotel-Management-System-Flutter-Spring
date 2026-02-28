class Leave {
  final int id;
  final int employeeId;
  final String employeeName;
  final String? employeeIdNumber;
  final String? department;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final String reason;
  final String status; // pending, approved, rejected, cancelled
  final String? appliedBy;
  final DateTime appliedDate;
  final String? approvedBy;
  final DateTime? approvedDate;
  final String? rejectionReason;
  final bool isPaid;

  Leave({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    this.employeeIdNumber,
    this.department,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    this.appliedBy,
    required this.appliedDate,
    this.approvedBy,
    this.approvedDate,
    this.rejectionReason,
    required this.isPaid,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'] ?? '',
      employeeIdNumber: json['employeeIdNumber'],
      department: json['department'],
      leaveType: json['leaveType'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      days: json['totalDays'] ?? json['days'] ?? 0,
      reason: json['reason'] ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      appliedBy: json['appliedBy'],
      appliedDate: json['appliedDate'] != null
          ? DateTime.parse(json['appliedDate'])
          : DateTime.now(),
      approvedBy: json['approvedBy'],
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      rejectionReason: json['rejectionReason'],
      isPaid: json['isPaid'] ?? true,
    );
  }
}