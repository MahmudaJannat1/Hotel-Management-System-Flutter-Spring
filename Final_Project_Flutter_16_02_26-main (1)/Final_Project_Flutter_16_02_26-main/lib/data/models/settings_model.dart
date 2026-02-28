class HotelSettings {
  final int id;
  final String hotelName;
  final String? address;
  final String? city;
  final String? country;
  final String? phone;
  final String? email;
  final String? website;
  final int? starRating;
  final String? logoUrl;
  final String? checkInTime;
  final String? checkOutTime;
  final String? currency;
  final double? taxRate;
  final String? timezone;
  final Map<String, dynamic>? preferences;

  HotelSettings({
    required this.id,
    required this.hotelName,
    this.address,
    this.city,
    this.country,
    this.phone,
    this.email,
    this.website,
    this.starRating,
    this.logoUrl,
    this.checkInTime,
    this.checkOutTime,
    this.currency,
    this.taxRate,
    this.timezone,
    this.preferences,
  });

  factory HotelSettings.fromJson(Map<String, dynamic> json) {
    return HotelSettings(
      id: json['id'] ?? 0,
      hotelName: json['name'] ?? json['hotelName'] ?? '',
      address: json['address'],
      city: json['city'],
      country: json['country'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      starRating: json['starRating'],
      logoUrl: json['logoUrl'],
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      currency: json['currency'] ?? 'BDT',
      taxRate: json['taxRate']?.toDouble() ?? 15.0,
      timezone: json['timezone'] ?? 'Asia/Dhaka',
      preferences: json['preferences'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': hotelName,
      'address': address,
      'city': city,
      'country': country,
      'phone': phone,
      'email': email,
      'website': website,
      'starRating': starRating,
      'logoUrl': logoUrl,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'currency': currency,
      'taxRate': taxRate,
      'timezone': timezone,
      'preferences': preferences,
    };
  }
}

class SystemSettings {
  final bool maintenanceMode;
  final bool allowRegistration;
  final bool emailNotifications;
  final bool smsNotifications;
  final int sessionTimeout;
  final int maxLoginAttempts;
  final String dateFormat;
  final String timeFormat;
  final String language;
  final Map<String, dynamic>? otherSettings;

  SystemSettings({
    required this.maintenanceMode,
    required this.allowRegistration,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.sessionTimeout,
    required this.maxLoginAttempts,
    required this.dateFormat,
    required this.timeFormat,
    required this.language,
    this.otherSettings,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      maintenanceMode: json['maintenanceMode'] ?? false,
      allowRegistration: json['allowRegistration'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? false,
      sessionTimeout: json['sessionTimeout'] ?? 30,
      maxLoginAttempts: json['maxLoginAttempts'] ?? 5,
      dateFormat: json['dateFormat'] ?? 'dd/MM/yyyy',
      timeFormat: json['timeFormat'] ?? 'HH:mm',
      language: json['language'] ?? 'en',
      otherSettings: json['otherSettings'],
    );
  }
}

class NotificationSettings {
  final bool bookingConfirmations;
  final bool checkInReminders;
  final bool checkOutReminders;
  final bool paymentReceipts;
  final bool lowStockAlerts;
  final bool taskAssignments;
  final bool leaveRequests;
  final bool payrollNotifications;

  NotificationSettings({
    required this.bookingConfirmations,
    required this.checkInReminders,
    required this.checkOutReminders,
    required this.paymentReceipts,
    required this.lowStockAlerts,
    required this.taskAssignments,
    required this.leaveRequests,
    required this.payrollNotifications,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      bookingConfirmations: json['bookingConfirmations'] ?? true,
      checkInReminders: json['checkInReminders'] ?? true,
      checkOutReminders: json['checkOutReminders'] ?? true,
      paymentReceipts: json['paymentReceipts'] ?? true,
      lowStockAlerts: json['lowStockAlerts'] ?? true,
      taskAssignments: json['taskAssignments'] ?? true,
      leaveRequests: json['leaveRequests'] ?? true,
      payrollNotifications: json['payrollNotifications'] ?? false,
    );
  }

  Map<String, bool> toMap() {
    return {
      'bookingConfirmations': bookingConfirmations,
      'checkInReminders': checkInReminders,
      'checkOutReminders': checkOutReminders,
      'paymentReceipts': paymentReceipts,
      'lowStockAlerts': lowStockAlerts,
      'taskAssignments': taskAssignments,
      'leaveRequests': leaveRequests,
      'payrollNotifications': payrollNotifications,
    };
  }
}