import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/data/models/guest_booking_model.dart';
import 'package:hotel_management_app/presentation/screens/guest/my_bookings_screen.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

import '../auth/login_screen.dart';
import 'guest_home_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final GuestBooking booking;

  const BookingDetailsScreen({Key? key, required this.booking}) : super(key: key);

  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareBooking,
          ),
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _downloadInvoice,
          ),
          // 🏠 Home Button
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => GuestHomeScreen()),
                    (route) => false,
              );
            },
            tooltip: 'Home',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Guest logout
              final guestProvider = Provider.of<GuestProvider>(context, listen: false);
              await guestProvider.logout();

              // Navigate to Admin Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.booking.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(widget.booking.status),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(widget.booking.status),
                    color: _getStatusColor(widget.booking.status),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Status',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          widget.booking.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(widget.booking.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.booking.status == 'confirmed' &&
                      widget.booking.checkInDate.isAfter(DateTime.now()))
                    TextButton(
                      onPressed: _showCancelDialog,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text('Cancel'),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Booking Reference
            Center(
              child: Column(
                children: [
                  Text(
                    'Booking Reference',
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

            // Hotel Contact Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hotel Contact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildContactRow(
                      Icons.phone,
                      'Call Hotel',
                      '+880 1234-567890',
                          () => _launchPhone('+8801234567890'),
                    ),
                    _buildContactRow(
                      Icons.email,
                      'Email Hotel',
                      'info@sunrisegrand.com',
                          () => _launchEmail('info@sunrisegrand.com', 'Booking Inquiry: ${widget.booking.bookingNumber}'),
                    ),
                    _buildContactRow(
                      Icons.location_on,
                      'Directions',
                      '123 Hotel Street, Gulshan',
                          () => _launchMaps('Gulshan,Dhaka'),
                    ),
                    _buildContactRow(
                      Icons.chat,
                      'WhatsApp',
                      '+880 1987-654321',
                          () => _launchWhatsApp('+8801987654321'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Room Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.meeting_room,
                      'Room',
                      '${widget.booking.roomNumber} - ${widget.booking.roomType}',
                    ),
                    _buildDetailRow(
                      Icons.people,
                      'Guests',
                      '${widget.booking.numberOfGuests}',
                    ),
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
                      '${widget.booking.numberOfNights}',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Guest Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guest Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.person,
                      'Name',
                      widget.booking.guestName,
                    ),
                    _buildDetailRow(
                      Icons.email,
                      'Email',
                      widget.booking.guestEmail,
                    ),
                    _buildDetailRow(
                      Icons.phone,
                      'Phone',
                      widget.booking.guestPhone,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Payment Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Special Requests
            if (widget.booking.specialRequests != null &&
                widget.booking.specialRequests!.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Special Requests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.booking.specialRequests!,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadInvoice,
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
                    onPressed: _shareBooking,
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

            if (widget.booking.status == 'confirmed' &&
                widget.booking.checkInDate.isAfter(DateTime.now()))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showCancelDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('CANCEL BOOKING'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
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
            flex: 2,
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

  Widget _buildContactRow(IconData icon, String label, String subtitle,
      VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.blue[800],
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14),
      contentPadding: EdgeInsets.zero,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
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

  // ========== URL Launcher Methods ==========

  Future<void> _launchPhone(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError('Could not launch phone dialer');
    }
  }

  Future<void> _launchEmail(String email, String subject) async {
    final url = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError('Could not launch email app');
    }
  }

  Future<void> _launchMaps(String query) async {
    final url = Uri.parse('https://maps.google.com/?q=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError('Could not open maps');
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final url = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError('Could not open WhatsApp');
    }
  }

  void _shareBooking() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share feature coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _downloadInvoice() {
    // TODO: Implement invoice download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice download coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _showCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('YES', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      final provider = Provider.of<GuestProvider>(context, listen: false);
      final success = await provider.cancelBooking(widget.booking.id);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to cancel booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}