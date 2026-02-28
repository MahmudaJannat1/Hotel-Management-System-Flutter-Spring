import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/data/models/guest_room_model.dart';
import 'package:hotel_management_app/presentation/screens/guest/room_details_screen.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

import '../auth/login_screen.dart';

class RoomListScreen extends StatefulWidget {
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? numberOfGuests;
  final String? roomType;
  final double? maxPrice;

  const RoomListScreen({
    Key? key,
    this.checkInDate,
    this.checkOutDate,
    this.numberOfGuests,
    this.roomType,
    this.maxPrice,
  }) : super(key: key);

  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  String _sortBy = 'price_low';
  String _selectedFilter = 'all';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRooms();
    });
  }

  Future<void> _loadRooms() async {
    if (!mounted) return;
    final provider = Provider.of<GuestProvider>(context, listen: false);

    if (widget.checkInDate != null && widget.checkOutDate != null) {
      await provider.searchRooms(
        checkIn: widget.checkInDate,
        checkOut: widget.checkOutDate,
        guests: widget.numberOfGuests,
        roomType: widget.roomType,
        maxPrice: widget.maxPrice,
      );
    } else {
      await provider.loadAvailableRooms();
    }
  }


  List<GuestRoom> _getFilteredAndSortedRooms(List<GuestRoom> rooms) {
    List<GuestRoom> filtered = List.from(rooms);

    // Apply filters
    if (_selectedFilter != 'all') {
      filtered = filtered.where((r) => r.roomType == _selectedFilter).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'capacity':
        filtered.sort((a, b) => b.maxOccupancy.compareTo(a.maxOccupancy));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Rooms'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
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
      body: Consumer<GuestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No rooms available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try different dates or filters',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final filteredRooms = _getFilteredAndSortedRooms(provider.rooms);
          final roomTypes = provider.getUniqueRoomTypes();

          return Column(
            children: [
              if (_showFilters) _buildFilterPanel(roomTypes),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = filteredRooms[index];
                    return _buildRoomCard(room);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterPanel(List<String> roomTypes) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => setState(() => _showFilters = false),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text('Room Type', style: TextStyle(fontWeight: FontWeight.w500)),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text('All'),
                selected: _selectedFilter == 'all',
                onSelected: (_) => setState(() => _selectedFilter = 'all'),
              ),
              ...roomTypes.map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: _selectedFilter == type,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = selected ? type : 'all');
                  },
                );
              }),
            ],
          ),
          SizedBox(height: 12),
          Text('Sort By', style: TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Price: Low to High'),
                  value: 'price_low',
                  groupValue: _sortBy,
                  onChanged: (value) => setState(() => _sortBy = value!),
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Price: High to Low'),
                  value: 'price_high',
                  groupValue: _sortBy,
                  onChanged: (value) => setState(() => _sortBy = value!),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildRoomCard(GuestRoom room) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailsScreen(room: room),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: room.images.isNotEmpty
                  ? _buildRoomImage(room.images.first)
                  : _buildPlaceholderImage(),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Room ${room.roomNumber}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              room.roomType,
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          Text(
                            'per night',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Up to ${room.maxOccupancy} guests'),
                      SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Floor ${room.floor}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: room.amenities.take(3).map((amenity) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// ইমেজ বিল্ড করার জন্য আলাদা মেথড
  Widget _buildRoomImage(String imagePath) {
    print('🖼️ Loading image for card: $imagePath');

    // অ্যাসেট ইমেজ
    return Image.asset(
      imagePath,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Error loading asset: $imagePath');
        print('Error details: $error');
        return Container(
          height: 160,
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 40, color: Colors.grey),
                Text(
                  'Image not found',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 160,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.hotel,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}