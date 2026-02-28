class GuestBooking {
  final int id;
  final String bookingNumber;
  final int roomId;
  final String roomNumber;
  final String roomType;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final String status;
  final double totalAmount;
  final double advancePayment;
  final double dueAmount;
  final String paymentMethod;
  final String? specialRequests;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final DateTime createdAt;
  final int? hotelId;

  GuestBooking({
    required this.id,
    required this.bookingNumber,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.status,
    required this.totalAmount,
    required this.advancePayment,
    required this.dueAmount,
    required this.paymentMethod,
    this.specialRequests,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.createdAt,
    this.hotelId,
  });

  factory GuestBooking.fromJson(Map<String, dynamic> json) {
    return GuestBooking(
      id: json['id'] ?? 0,
      bookingNumber: json['bookingNumber'] ?? '',
      roomId: json['roomId'] ?? 0,
      roomNumber: json['roomNumber'] ?? '',
      roomType: json['roomTypeName'] ?? '',
      checkInDate: json['checkInDate'] != null
          ? DateTime.parse(json['checkInDate'])
          : DateTime.now(),
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'])
          : DateTime.now(),
      numberOfGuests: json['numberOfGuests'] ?? 1,
      status: json['status'] ?? 'pending',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      advancePayment: (json['advancePayment'] ?? 0).toDouble(),
      dueAmount: (json['dueAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      specialRequests: json['specialRequests'],
      guestName: json['guestName'] ?? '',
      guestEmail: json['guestEmail'] ?? '',
      guestPhone: json['guestPhone'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      hotelId: json['hotelId'],
    );
  }

// guest_booking_model.dart

  Map<String, dynamic> toMap() {
    var map = {
      'bookingNumber': bookingNumber,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'roomType': roomType,
      'checkInDate': checkInDate.toIso8601String().split('T')[0],
      'checkOutDate': checkOutDate.toIso8601String().split('T')[0],
      'numberOfGuests': numberOfGuests,
      'status': status,
      'totalAmount': totalAmount,
      'advancePayment': advancePayment,
      'dueAmount': dueAmount,
      'paymentMethod': paymentMethod,
      'specialRequests': specialRequests,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'guestPhone': guestPhone,
      'createdAt': createdAt.toIso8601String(),
      'hotelId': hotelId,
    };

    // 🔴 id শুধু তখনই যোগ করুন যখন এটি 0 এর বেশি হয়
    if (id > 0) {
      map['id'] = id;
    }

    return map;
  }
  factory GuestBooking.fromMap(Map<String, dynamic> map) {
    return GuestBooking(
      id: map['id'] ?? 0,
      bookingNumber: map['bookingNumber'] ?? '',
      roomId: map['roomId'] ?? 0,
      roomNumber: map['roomNumber'] ?? '',
      roomType: map['roomType'] ?? '',
      checkInDate: map['checkInDate'] != null
          ? DateTime.parse(map['checkInDate'])
          : DateTime.now(),
      checkOutDate: map['checkOutDate'] != null
          ? DateTime.parse(map['checkOutDate'])
          : DateTime.now(),
      numberOfGuests: map['numberOfGuests'] ?? 1,
      status: map['status'] ?? 'pending',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      advancePayment: (map['advancePayment'] ?? 0).toDouble(),
      dueAmount: (map['dueAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      specialRequests: map['specialRequests'],
      guestName: map['guestName'] ?? '',
      guestEmail: map['guestEmail'] ?? '',
      guestPhone: map['guestPhone'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      hotelId: map['hotelId'],
    );
  }

  int get numberOfNights => checkOutDate.difference(checkInDate).inDays;
}