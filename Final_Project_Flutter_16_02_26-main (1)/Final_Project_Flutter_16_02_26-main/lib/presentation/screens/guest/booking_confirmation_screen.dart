import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/data/models/guest_booking_model.dart';
import 'package:hotel_management_app/presentation/screens/guest/my_bookings_screen.dart';
import 'package:hotel_management_app/presentation/screens/guest/guest_home_screen.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final GuestBooking booking;

  const BookingConfirmationScreen({Key? key, required this.booking}) : super(key: key);

  @override
  _BookingConfirmationScreenState createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmed'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => GuestHomeScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success Animation
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),

            // Success Message
            Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your booking has been successfully confirmed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),

            // Booking Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Number
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Booking Number',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.booking.bookingNumber,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Hotel Info
                    _buildDetailRow(
                      Icons.hotel,
                      'Hotel',
                      'Sunrise Grand Hotel',
                    ),
                    Divider(),

                    // Room Info
                    _buildDetailRow(
                      Icons.meeting_room,
                      'Room',
                      '${widget.booking.roomNumber} - ${widget.booking.roomType}',
                    ),
                    Divider(),

                    // Guest Name
                    _buildDetailRow(
                      Icons.person,
                      'Guest',
                      widget.booking.guestName,
                    ),
                    Divider(),

                    // Check-in/out
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Check-in',
                      '${widget.booking.checkInDate.day}/${widget.booking.checkInDate.month}/${widget.booking.checkInDate.year}',
                    ),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Check-out',
                      '${widget.booking.checkOutDate.day}/${widget.booking.checkOutDate.month}/${widget.booking.checkOutDate.year}',
                    ),
                    _buildDetailRow(
                      Icons.nights_stay,
                      'Nights',
                      '${widget.booking.numberOfNights} nights',
                    ),
                    Divider(),

                    // Guests
                    _buildDetailRow(
                      Icons.people,
                      'Guests',
                      '${widget.booking.numberOfGuests}',
                    ),
                    Divider(),

                    // Payment
                    _buildDetailRow(
                      Icons.payment,
                      'Payment Method',
                      _getPaymentMethodName(widget.booking.paymentMethod),
                    ),
                    _buildDetailRow(
                      Icons.attach_money,
                      'Total Amount',
                      CurrencyFormatter.format(widget.booking.totalAmount),
                      valueColor: Colors.green,
                    ),
                    if (widget.booking.advancePayment > 0) ...[
                      _buildDetailRow(
                        Icons.money,
                        'Advance Paid',
                        CurrencyFormatter.format(widget.booking.advancePayment),
                        valueColor: Colors.blue,
                      ),
                      _buildDetailRow(
                        Icons.money_off,
                        'Due at Hotel',
                        CurrencyFormatter.format(widget.booking.dueAmount),
                        valueColor: Colors.orange,
                      ),
                    ],
                    if (widget.booking.specialRequests != null) ...[
                      Divider(),
                      _buildDetailRow(
                        Icons.note,
                        'Special Requests',
                        widget.booking.specialRequests!,
                        isMultiline: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Download invoice
                    },
                    icon: Icon(Icons.download),
                    label: Text('Invoice'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Share booking
                    },
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // View Bookings Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyBookingsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('VIEW MY BOOKINGS'),
              ),
            ),
            SizedBox(height: 8),

            // Back to Home
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => GuestHomeScreen()),
                      (route) => false,
                );
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor, bool isMultiline = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment:
        isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'pay_at_hotel':
        return 'Pay at Hotel';
      case 'card':
        return 'Credit/Debit Card';
      case 'mobile_banking':
        return 'Mobile Banking';
      default:
        return method;
    }
  }
}