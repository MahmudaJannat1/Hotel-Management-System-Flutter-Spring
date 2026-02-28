class RevenueReport {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final String generatedAt;

  // Summary
  final double totalRevenue;
  final double totalRoomRevenue;
  final double totalFnbRevenue;
  final double totalOtherRevenue;
  final double averageDailyRate;
  final double revenuePerAvailableRoom;
  final int totalBookings;
  final int cancelledBookings;
  final int noShowBookings;

  // Daily breakdown
  final List<DailyRevenue> dailyRevenue;

  // Payment method wise
  final Map<String, double> paymentMethodRevenue;

  // Room type wise
  final Map<String, double> roomTypeRevenue;

  RevenueReport({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.totalRevenue,
    required this.totalRoomRevenue,
    required this.totalFnbRevenue,
    required this.totalOtherRevenue,
    required this.averageDailyRate,
    required this.revenuePerAvailableRoom,
    required this.totalBookings,
    required this.cancelledBookings,
    required this.noShowBookings,
    required this.dailyRevenue,
    required this.paymentMethodRevenue,
    required this.roomTypeRevenue,
  });

  factory RevenueReport.fromJson(Map<String, dynamic> json) {
    return RevenueReport(
      reportType: json['reportType'] ?? 'REVENUE_REPORT',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      generatedAt: json['generatedAt'] ?? '',
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalRoomRevenue: (json['totalRoomRevenue'] ?? 0).toDouble(),
      totalFnbRevenue: (json['totalFnbRevenue'] ?? 0).toDouble(),
      totalOtherRevenue: (json['totalOtherRevenue'] ?? 0).toDouble(),
      averageDailyRate: (json['averageDailyRate'] ?? 0).toDouble(),
      revenuePerAvailableRoom: (json['revenuePerAvailableRoom'] ?? 0).toDouble(),
      totalBookings: json['totalBookings'] ?? 0,
      cancelledBookings: json['cancelledBookings'] ?? 0,
      noShowBookings: json['noShowBookings'] ?? 0,
      dailyRevenue: (json['dailyRevenue'] as List? ?? [])
          .map((d) => DailyRevenue.fromJson(d))
          .toList(),
      paymentMethodRevenue: Map<String, double>.from(json['paymentMethodRevenue'] ?? {}),
      roomTypeRevenue: Map<String, double>.from(json['roomTypeRevenue'] ?? {}),
    );
  }
}

class DailyRevenue {
  final DateTime date;
  final double roomRevenue;
  final double fnbRevenue;
  final double otherRevenue;
  final double totalRevenue;
  final int bookings;

  DailyRevenue({
    required this.date,
    required this.roomRevenue,
    required this.fnbRevenue,
    required this.otherRevenue,
    required this.totalRevenue,
    required this.bookings,
  });

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      roomRevenue: (json['roomRevenue'] ?? 0).toDouble(),
      fnbRevenue: (json['fnbRevenue'] ?? 0).toDouble(),
      otherRevenue: (json['otherRevenue'] ?? 0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      bookings: json['bookings'] ?? 0,
    );
  }
}