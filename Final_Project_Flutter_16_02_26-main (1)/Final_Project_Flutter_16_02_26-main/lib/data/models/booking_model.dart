class Booking {
  final int id;
  final String bookingNumber;
  final int guestId;
  final String guestName;
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
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.bookingNumber,
    required this.guestId,
    required this.guestName,
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
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      bookingNumber: json['bookingNumber'] ?? '',
      guestId: json['guestId'] ?? 0,
      guestName: json['guestName'] ?? '',
      roomId: json['roomId'] ?? 0,
      roomNumber: json['roomNumber'] ?? '',
      roomType: json['roomTypeName'] ?? '',
      checkInDate: DateTime.parse(json['checkInDate'] ?? DateTime.now().toIso8601String()),
      checkOutDate: DateTime.parse(json['checkOutDate'] ?? DateTime.now().toIso8601String()),
      numberOfGuests: json['numberOfGuests'] ?? 1,
      status: json['status'] ?? 'pending',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      advancePayment: (json['advancePayment'] ?? 0).toDouble(),
      dueAmount: (json['dueAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      specialRequests: json['specialRequests'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  int get numberOfNights => checkOutDate.difference(checkInDate).inDays;
}