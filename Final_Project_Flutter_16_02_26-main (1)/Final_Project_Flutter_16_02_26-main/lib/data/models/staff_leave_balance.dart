// lib/data/models/staff/staff_leave_balance.dart

class StaffLeaveBalance {
  final int staffId;
  final String staffName;
  final int sickLeaveTotal;
  final int sickLeaveUsed;
  final int casualLeaveTotal;
  final int casualLeaveUsed;
  final int annualLeaveTotal;
  final int annualLeaveUsed;
  final int emergencyLeaveTotal;
  final int emergencyLeaveUsed;

  StaffLeaveBalance({
    required this.staffId,
    required this.staffName,
    this.sickLeaveTotal = 10,
    this.sickLeaveUsed = 0,
    this.casualLeaveTotal = 12,
    this.casualLeaveUsed = 0,
    this.annualLeaveTotal = 20,
    this.annualLeaveUsed = 0,
    this.emergencyLeaveTotal = 5,
    this.emergencyLeaveUsed = 0,
  });

  int get sickLeaveRemaining => sickLeaveTotal - sickLeaveUsed;
  int get casualLeaveRemaining => casualLeaveTotal - casualLeaveUsed;
  int get annualLeaveRemaining => annualLeaveTotal - annualLeaveUsed;
  int get emergencyLeaveRemaining => emergencyLeaveTotal - emergencyLeaveUsed;

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'sickLeaveTotal': sickLeaveTotal,
      'sickLeaveUsed': sickLeaveUsed,
      'casualLeaveTotal': casualLeaveTotal,
      'casualLeaveUsed': casualLeaveUsed,
      'annualLeaveTotal': annualLeaveTotal,
      'annualLeaveUsed': annualLeaveUsed,
      'emergencyLeaveTotal': emergencyLeaveTotal,
      'emergencyLeaveUsed': emergencyLeaveUsed,
    };
  }

  factory StaffLeaveBalance.fromMap(Map<String, dynamic> map) {
    return StaffLeaveBalance(
      staffId: map['staffId'] ?? 0,
      staffName: map['staffName'] ?? '',
      sickLeaveTotal: map['sickLeaveTotal'] ?? 10,
      sickLeaveUsed: map['sickLeaveUsed'] ?? 0,
      casualLeaveTotal: map['casualLeaveTotal'] ?? 12,
      casualLeaveUsed: map['casualLeaveUsed'] ?? 0,
      annualLeaveTotal: map['annualLeaveTotal'] ?? 20,
      annualLeaveUsed: map['annualLeaveUsed'] ?? 0,
      emergencyLeaveTotal: map['emergencyLeaveTotal'] ?? 5,
      emergencyLeaveUsed: map['emergencyLeaveUsed'] ?? 0,
    );
  }
}