import 'package:flutter/material.dart';
import 'package:hotel_management_app/presentation/screens/guest/room_search_screen.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/data/models/guest_booking_model.dart';
import 'package:hotel_management_app/presentation/screens/guest/booking_details_screen.dart';
import 'package:hotel_management_app/presentation/screens/guest/booking_form_screen.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

import '../auth/login_screen.dart';
import 'guest_home_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {  // ✅ 1. Mixin যোগ করুন

  late TabController _tabController;  // ✅ 2. TabController ডিক্লেয়ার করুন
  int _selectedTab = 0; // 0: upcoming, 1: past, 2: cancelled
  String? _guestEmail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });

    // Login check করবেন না, শুধু user load করুন
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGuestInfo();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  Future<void> _loadGuestInfo() async {
    final provider = Provider.of<GuestProvider>(context, listen: false);

    if (provider.currentUser != null) {
      setState(() {
        _guestEmail = provider.currentUser!.email;
      });
      _loadBookings();
    } else {
      // Not logged in - show login prompt
      setState(() {
        _guestEmail = null;
      });
    }
  }

  Future<void> _loadBookings() async {
    final provider = Provider.of<GuestProvider>(context, listen: false);

    // ✅ currentUser থেকে email নিন
    if (provider.currentUser != null) {
      final email = provider.currentUser!.email;
      print('📚 Loading bookings for: $email');
      await provider.loadBookingsByGuest(email);
      print('📊 Bookings loaded: ${provider.bookings.length}');
    } else {
      print('⚠️ No user logged in');
      setState(() {
        _guestEmail = null;
      });
    }
  }

  List<GuestBooking> _getFilteredBookings(List<GuestBooking> bookings) {
    final now = DateTime.now();

    // 🟢 ডিবাগ: সব bookings প্রিন্ট করুন
    for (var b in bookings) {
      print('📅 Booking: ${b.bookingNumber}, CheckIn: ${b.checkInDate}, Status: ${b.status}');
    }

    // 🔴 টেস্টিং: সব bookings সব tab এ দেখান (তারপর fix করবেন)
    return bookings;  // ← এই লাইনটা যোগ করুন

    // নিচের code temporary disable
    /*
  switch (_selectedTab) {
    case 0: // Upcoming
      return bookings.where((b) =>
        b.checkInDate.isAfter(now) && b.status != 'cancelled'
      ).toList();
    case 1: // Past
      return bookings.where((b) =>
        b.checkOutDate.isBefore(now) && b.status != 'cancelled'
      ).toList();
    case 2: // Cancelled
      return bookings.where((b) => b.status == 'cancelled').toList();
    default:
      return [];
  }
  */
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          // 🏠 Home Button
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // GuestHomeScreen এ যাবে (যার body তে RoomSearchScreen আছে)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => GuestHomeScreen()),
                    (route) => false,
              );
            },
            tooltip: 'Home',
          ),

          // 🚪 Logout Button
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final guestProvider = Provider.of<GuestProvider>(context, listen: false);
              await guestProvider.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
        elevation: 0,

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Consumer<GuestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (_guestEmail == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Please login to view your bookings',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to login
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            );
          }

          final filteredBookings = _getFilteredBookings(provider.bookings);

          if (filteredBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_online, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    _selectedTab == 0
                        ? 'No upcoming bookings'
                        : _selectedTab == 1
                        ? 'No past bookings'
                        : 'No cancelled bookings',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  if (_selectedTab == 0)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomSearchScreen(),
                          ),
                        );
                      },
                      child: Text('Book a Room'),
                    ),

                  SizedBox(height: 8),

                  // Back to Home
                  TextButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.blue[800],  // ✅ color দেওয়া আছে তো?
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return _buildBookingCard(booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(GuestBooking booking) {
    Color statusColor = booking.status == 'confirmed'
        ? Colors.green
        : booking.status == 'cancelled'
        ? Colors.red
        : Colors.orange;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsScreen(booking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt,
                      color: Colors.blue[800],
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking #${booking.bookingNumber.substring(0, 8)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Room ${booking.roomNumber} • ${booking.roomType}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${booking.checkInDate.day}/${booking.checkInDate.month} - '
                        '${booking.checkOutDate.day}/${booking.checkOutDate.month}',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.nights_stay, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${booking.numberOfNights} nights',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${CurrencyFormatter.format(booking.totalAmount)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  if (booking.status == 'confirmed' &&
                      booking.checkInDate.isAfter(DateTime.now()))
                    TextButton(
                      onPressed: () {
                        _showCancelDialog(context, booking.id);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('Cancel'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context, int bookingId) async {
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
            child: Text('YES'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<GuestProvider>(context, listen: false);
      final success = await provider.cancelBooking(bookingId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload bookings
        if (_guestEmail != null) {
          await provider.loadBookingsByGuest(_guestEmail!);
        }
      }
    }
  }
}