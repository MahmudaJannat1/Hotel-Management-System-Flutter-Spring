// lib/data/models/staff/staff_attendance_model.dart

class StaffAttendance {
  final int id;
  final int staffId;
  final String staffName;
  final DateTime date;
  final String status; // Present, Absent, Late, Half-day
  final String? checkInTime;
  final String? checkOutTime;
  final String? notes;

  StaffAttendance({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'staffId': staffId,
      'staffName': staffName,
      'date': date.toIso8601String().split('T')[0],
      'status': status,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'notes': notes,
    };
    if (id > 0) {
      map['id'] = id;
    }
    return map;
  }

  factory StaffAttendance.fromMap(Map<String, dynamic> map) {
    return StaffAttendance(
      id: map['id'] ?? 0,
      staffId: map['staffId'] ?? 0,
      staffName: map['staffName'] ?? '',
      date: DateTime.parse(map['date']),
      status: map['status'] ?? 'Present',
      checkInTime: map['checkInTime'],
      checkOutTime: map['checkOutTime'],
      notes: map['notes'],
    );
  }

  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;

  String get workingHours {
    if (checkInTime == null || checkOutTime == null) return '--';

    final checkIn = _parseTime(checkInTime!);
    final checkOut = _parseTime(checkOutTime!);

    final hours = checkOut.difference(checkIn).inHours;
    final minutes = checkOut.difference(checkIn).inMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  DateTime _parseTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    return DateTime(
      now.year, now.month, now.day,
      int.parse(parts[0]), int.parse(parts[1]),
    );
  }
}