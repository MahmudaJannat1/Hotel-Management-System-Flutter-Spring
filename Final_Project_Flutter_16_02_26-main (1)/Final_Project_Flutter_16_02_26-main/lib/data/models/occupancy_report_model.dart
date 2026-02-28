class OccupancyReport {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final String generatedAt;

  // Summary
  final int totalRooms;
  final int totalOccupiedRooms;
  final int totalAvailableRooms;
  final int totalMaintenanceRooms;
  final double averageOccupancyRate;

  // Daily breakdown
  final List<DailyOccupancy> dailyOccupancy;

  // Room type wise
  final Map<String, RoomTypeOccupancy> roomTypeStats;

  OccupancyReport({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.totalRooms,
    required this.totalOccupiedRooms,
    required this.totalAvailableRooms,
    required this.totalMaintenanceRooms,
    required this.averageOccupancyRate,
    required this.dailyOccupancy,
    required this.roomTypeStats,
  });

  factory OccupancyReport.fromJson(Map<String, dynamic> json) {
    return OccupancyReport(
      reportType: json['reportType'] ?? 'OCCUPANCY_REPORT',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      generatedAt: json['generatedAt'] ?? '',
      totalRooms: json['totalRooms'] ?? 0,
      totalOccupiedRooms: json['totalOccupiedRooms'] ?? 0,
      totalAvailableRooms: json['totalAvailableRooms'] ?? 0,
      totalMaintenanceRooms: json['totalMaintenanceRooms'] ?? 0,
      averageOccupancyRate: (json['averageOccupancyRate'] ?? 0).toDouble(),
      dailyOccupancy: (json['dailyOccupancy'] as List? ?? [])
          .map((d) => DailyOccupancy.fromJson(d))
          .toList(),
      roomTypeStats: (json['roomTypeStats'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, RoomTypeOccupancy.fromJson(value))),
    );
  }
}

class DailyOccupancy {
  final DateTime date;
  final int occupiedRooms;
  final int availableRooms;
  final int maintenanceRooms;
  final double occupancyRate;
  final double revenue;

  DailyOccupancy({
    required this.date,
    required this.occupiedRooms,
    required this.availableRooms,
    required this.maintenanceRooms,
    required this.occupancyRate,
    required this.revenue,
  });

  factory DailyOccupancy.fromJson(Map<String, dynamic> json) {
    return DailyOccupancy(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      occupiedRooms: json['occupiedRooms'] ?? 0,
      availableRooms: json['availableRooms'] ?? 0,
      maintenanceRooms: json['maintenanceRooms'] ?? 0,
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class RoomTypeOccupancy {
  final String roomTypeName;
  final int totalRooms;
  final int occupiedRooms;
  final double occupancyRate;
  final double averageRate;
  final double totalRevenue;

  RoomTypeOccupancy({
    required this.roomTypeName,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.occupancyRate,
    required this.averageRate,
    required this.totalRevenue,
  });

  factory RoomTypeOccupancy.fromJson(Map<String, dynamic> json) {
    return RoomTypeOccupancy(
      roomTypeName: json['roomTypeName'] ?? '',
      totalRooms: json['totalRooms'] ?? 0,
      occupiedRooms: json['occupiedRooms'] ?? 0,
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      averageRate: (json['averageRate'] ?? 0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}