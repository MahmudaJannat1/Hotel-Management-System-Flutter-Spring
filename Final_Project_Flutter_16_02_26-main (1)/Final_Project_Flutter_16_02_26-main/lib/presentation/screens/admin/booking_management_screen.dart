import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/booking_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';
import 'package:hotel_management_app/data/models/booking_model.dart';

import 'add_edit_booking_screen.dart';

class BookingManagementScreen extends StatefulWidget {
  @override
  _BookingManagementScreenState createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  String _selectedFilter = 'all'; // all, pending, confirmed, checked_in, checked_out, cancelled
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    await bookingProvider.loadAllBookings();
  }

  List<Booking> _getFilteredBookings(List<Booking> bookings) {
    List<Booking> filtered = List.from(bookings);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((booking) {
        return booking.guestName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            booking.bookingNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            booking.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((b) => b.status.toLowerCase() == _selectedFilter).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminBookings),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        toolbarHeight: 90,
        title: Text('Booking Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.adminAddBooking)
                  .then((_) => _loadBookings());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bookings...',
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              // Filter Chips
              Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('All', 'all', Icons.list),
                    _buildFilterChip('Pending', 'pending', Icons.pending, Colors.orange),
                    _buildFilterChip('Confirmed', 'confirmed', Icons.check_circle, Colors.green),
                    _buildFilterChip('Checked In', 'checked_in', Icons.login, Colors.blue),
                    _buildFilterChip('Checked Out', 'checked_out', Icons.logout, Colors.purple),
                    _buildFilterChip('Cancelled', 'cancelled', Icons.cancel, Colors.red),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.bookings.isEmpty) {
            return LoadingIndicator(message: 'Loading bookings...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadBookings,
            );
          }

          final filteredBookings = _getFilteredBookings(provider.bookings);

          if (filteredBookings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadBookings,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                return _buildBookingCard(booking, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, [Color? color]) {
    bool isSelected = _selectedFilter == value;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : (color ?? Colors.black54)),
            SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedFilter = selected ? value : 'all'),
        backgroundColor: Colors.grey[200],
        selectedColor: color ?? Theme.of(context).primaryColor,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, BookingProvider provider) {
    Color statusColor = _getStatusColor(booking.status);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditBookingScreen(
                bookingId: booking.id,
                isViewOnly: false,
              ),
            ),
          ).then((_) => _loadBookings());
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.receipt, color: statusColor, size: 30),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.bookingNumber,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          booking.guestName,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.hotel, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('Room ${booking.roomNumber}', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${booking.checkInDate} - ${booking.checkOutDate}',
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Amount', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      Text(
                        CurrencyFormatter.format(booking.totalAmount),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (booking.status == 'pending') ...[
                        ElevatedButton(
                          onPressed: () => _confirmBooking(context, booking.id, provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text('Confirm', style: TextStyle(fontSize: 12)),
                        ),
                        SizedBox(width: 8),
                      ],
                      // 🔥 Delete Button - সবসময় দেখাবে
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBooking(context, booking.id, provider),
                        tooltip: 'Delete Booking',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteBooking(BuildContext context, int id, BookingProvider provider) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Booking'),
        content: Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteBooking(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'checked_in': return Colors.blue;
      case 'checked_out': return Colors.purple;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _confirmBooking(BuildContext context, int id, BookingProvider provider) async {
    final confirmed = await _showConfirmDialog(context, 'Confirm Booking');
    if (confirmed) {
      await provider.updateBookingStatus(id, 'confirmed');
    }
  }

  Future<void> _cancelBooking(BuildContext context, int id, BookingProvider provider) async {
    final confirmed = await _showConfirmDialog(context, 'Cancel Booking');
    if (confirmed) {
      await provider.updateBookingStatus(id, 'cancelled');
    }
  }

  Future<bool> _showConfirmDialog(BuildContext context, String title) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('NO')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('YES')),
        ],
      ),
    ) ?? false;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text('No bookings found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Try changing filters'
                : 'Click + to add a new booking',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}