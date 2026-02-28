import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/data/models/guest_room_model.dart';
import 'package:hotel_management_app/presentation/screens/guest/booking_form_screen.dart';
import 'package:hotel_management_app/presentation/screens/guest/guest_login_screen.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

import '../auth/login_screen.dart';

class RoomDetailsScreen extends StatefulWidget {
  final GuestRoom room;

  const RoomDetailsScreen({Key? key, required this.room}) : super(key: key);

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  int _selectedImageIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoomDetails();
    });
  }

  Future<void> _loadRoomDetails() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<GuestProvider>(context, listen: false);
    await provider.loadRoomById(widget.room.id);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${room.roomNumber}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Add to wishlist
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // TODO: Share room details
            },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            _buildImageGallery(room),

            // Room Info
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.roomType,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Room ${room.roomNumber} • Floor ${room.floor}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(room.price),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          Text(
                            'per night',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Availability Status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: room.isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          room.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: room.isAvailable ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          room.isAvailable ? 'Available' : 'Not Available',
                          style: TextStyle(
                            color: room.isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Description
                  _buildSectionTitle('Description'),
                  SizedBox(height: 8),
                  Text(
                    room.description.isNotEmpty
                        ? room.description
                        : 'No description available for this room.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  SizedBox(height: 20),

                  // Amenities
                  _buildSectionTitle('Amenities'),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: room.amenities.isNotEmpty
                        ? room.amenities.map((amenity) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      );
                    }).toList()
                        : [Text('No amenities listed')],
                  ),
                  SizedBox(height: 20),

                  // Room Details
                  _buildSectionTitle('Room Details'),
                  SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.people,
                    'Max Occupancy',
                    '${room.maxOccupancy} guests',
                  ),
                  _buildDetailRow(
                    Icons.straighten,
                    'Room Size',
                    'Not specified',
                  ),
                  _buildDetailRow(
                    Icons.king_bed,
                    'Bed Type',
                    'King size bed',
                  ),
                  _buildDetailRow(
                    Icons.wifi,
                    'WiFi',
                    'Free high-speed WiFi',
                  ),
                  _buildDetailRow(
                    Icons.ac_unit,
                    'Air Conditioning',
                    'Available',
                  ),
                  SizedBox(height: 20),

                  // Policies
                  _buildSectionTitle('Policies'),
                  SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: Colors.grey[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPolicyRow(
                            Icons.access_time,
                            'Check-in: 2:00 PM',
                            'Check-out: 12:00 PM',
                          ),
                          Divider(),
                          _buildPolicyRow(
                            Icons.cancel,
                            'Free cancellation',
                            'Up to 24 hours before check-in',
                          ),
                          Divider(),
                          _buildPolicyRow(
                            Icons.payment,
                            'Payment',
                            'Pay at hotel or online',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Book Button with Login Check
                  if (room.isAvailable)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print('🖱️ Book button clicked for room: ${widget.room.id}');

                          final provider = Provider.of<GuestProvider>(context, listen: false);

                          if (provider.isLoggedIn) {
                            // Logged in - go to booking form
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingFormScreen(
                                  room: widget.room,
                                ),
                              ),
                            );
                          } else {
                            // Not logged in - go to login screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GuestLoginScreen(
                                  redirectRoom: widget.room,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'BOOK NOW',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(GuestRoom room) {
    if (room.images.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.hotel, size: 80, color: Colors.grey[500]),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: room.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    room.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  );
                },
              ),
              // Image Counter
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedImageIndex + 1}/${room.images.length}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue[800]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}