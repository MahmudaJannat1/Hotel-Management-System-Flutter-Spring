import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/room_provider.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/presentation/screens/admin/add_edit_room_screen.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/room_model.dart';
import '../../widgets/common_drawer.dart';

class RoomManagementScreen extends StatefulWidget {
  @override
  _RoomManagementScreenState createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  String _selectedFilter = 'all'; // all, available, occupied, maintenance, reserved
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ এইভাবে data load করুন
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRooms();
    });
  }
  Future<void> _loadRooms() async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    await roomProvider.loadAllRooms();
    if (mounted) {  // ✅ এই check টা দিন
      setState(() {
        // যদি কিছু update করতে চান
      });
    }
  }

  List<Room> _getFilteredRooms(List<Room> rooms) {
    List<Room> filtered = List.from(rooms);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((room) {
        return room.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            room.roomType.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    switch (_selectedFilter) {
      case 'available':
        filtered = filtered.where((r) => r.status == 'AVAILABLE').toList();
        break;
      case 'occupied':
        filtered = filtered.where((r) => r.status == 'OCCUPIED').toList();
        break;
      case 'maintenance':
        filtered = filtered.where((r) => r.status == 'MAINTENANCE').toList();
        break;
      case 'reserved':
        filtered = filtered.where((r) => r.status == 'RESERVED').toList();
        break;
    }

    return filtered;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminRooms),
      appBar: AppBar(
        toolbarHeight: 60, // ✅ title cut issue fixed
        centerTitle: true,

        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        title: Text(
          'Room Management',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,

        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRooms,
          ),
        ],

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(140), // ✅ enough space
          child: Column(
            children: [
              // 🔍 Search bar
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search rooms...',
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

              // 🎯 Filter chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('All', 'all', Icons.hotel),
                    _buildFilterChip('Available', 'available', Icons.check_circle, Colors.green),
                    _buildFilterChip('Occupied', 'occupied', Icons.person, Colors.orange),
                    _buildFilterChip('Maintenance', 'maintenance', Icons.build, Colors.red),
                    _buildFilterChip('Reserved', 'reserved', Icons.book, Colors.blue),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditRoomScreen()),
          ).then((_) => _loadRooms());
        },
      ),
      body: Consumer<RoomProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.rooms.isEmpty) {
            return LoadingIndicator(message: 'Loading rooms...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadRooms,
            );
          }

          final filteredRooms = _getFilteredRooms(provider.rooms);

          if (filteredRooms.isEmpty) {
            return _buildEmptyState(provider);
          }

          return RefreshIndicator(
            onRefresh: _loadRooms,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredRooms.length,
              itemBuilder: (context, index) {
                final room = filteredRooms[index];
                return _buildRoomCard(room, provider);
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
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: color ?? Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room, RoomProvider provider) {
    print('🏠 Room ID: ${room.id}');
    print('📸 Images list: ${room.images}');
    print('🖼️ First image: ${room.images.isNotEmpty ? room.images.first : 'EMPTY'}');
    print('🔗 Full URL: ${room.firstImageUrl}');
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          provider.selectRoom(room);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditRoomScreen(room: room),
            ),
          ).then((_) => _loadRooms());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (room.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      room.images.first.startsWith('http')
                          ? room.images.first
                          : 'http://192.168.0.103:8080${room.images.first}',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text('Image not available'),
                        ),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  )
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(8),
                //   child: // RoomCard-এ image দেখান
                //   Image.network(
                //     //'http://192.168.20.50:8080${room.images.first}',
                //     'http://192.168.0.103:8080${room.images.first}',
                //     height: 150,
                //     width: double.infinity,
                //     fit: BoxFit.cover,
                //     errorBuilder: (context, error, stackTrace) {
                //       return Container(
                //         height: 150,
                //         color: Colors.grey[300],
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Icon(Icons.broken_image, size: 40, color: Colors.grey),
                //             SizedBox(height: 4),
                //             Text('Image not available', style: TextStyle(color: Colors.grey)),
                //           ],
                //         ),
                //       );
                //     },
                //     loadingBuilder: (context, child, loadingProgress) {
                //       if (loadingProgress == null) return child;
                //       return Container(
                //         height: 150,
                //         color: Colors.grey[200],
                //         child: Center(child: CircularProgressIndicator()),
                //       );
                //     },
                //   ),
                // )
              else
              // 🔥 No image placeholder
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hotel, size: 50, color: Colors.grey[400]),
                      SizedBox(height: 8),
                      Text(
                        'No Image',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 12),

              // Room info row
// Room info row te wrap with Expanded:

              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: room.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.hotel, color: room.statusColor, size: 30),
                  ),
                  SizedBox(width: 12),
                  Expanded(  // ✅ Already there - good
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room ${room.roomNumber}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          room.roomType,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 1,              // ✅ Add this
                          overflow: TextOverflow.ellipsis,  // ✅ Add this
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: room.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      room.statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: room.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Room features
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Max ${room.maxOccupancy} guests',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Floor ${room.floor}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Price and status buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price per night',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      Text(
                        CurrencyFormatter.format(room.price),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStatusButton(
                        'Available',
                        Icons.check_circle,
                        Colors.green,
                        room.status == 'AVAILABLE',
                            () => _updateStatus(room, 'AVAILABLE', provider),
                      ),
                      SizedBox(width: 4),
                      _buildStatusButton(
                        'Occupied',
                        Icons.person,
                        Colors.orange,
                        room.status == 'OCCUPIED',
                            () => _updateStatus(room, 'OCCUPIED', provider),
                      ),
                      SizedBox(width: 4),
                      _buildStatusButton(
                        'Maint',
                        Icons.build,
                        Colors.red,
                        room.status == 'MAINTENANCE',
                            () => _updateStatus(room, 'MAINTENANCE', provider),
                      ),
                    ],
                  ),
                ],
              ),

              // Amenities
              if (room.amenities.isNotEmpty) ...[
                SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
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

              Divider(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      provider.selectRoom(room);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditRoomScreen(room: room),
                        ),
                      ).then((_) => _loadRooms());
                    },
                  ),
// room_management_screen.dart e:

                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await _showConfirmDialog(
                        context,
                        'Delete Room',
                        'Are you sure you want to delete Room ${room.roomNumber}?',
                      );
                      if (confirmed) {
                        final success = await provider.deleteRoom(room.id);  // Just get bool

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Room deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (!success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.error ?? 'Failed to delete room'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, IconData icon, Color color, bool isActive, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: isActive ? Colors.white : color),
                SizedBox(width: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(Room room, String status, RoomProvider provider) async {
    if (room.status == status) return;

    final confirmed = await _showConfirmDialog(
      context,
      'Update Status',
      'Change Room ${room.roomNumber} status to ${status.toLowerCase()}?',
    );

    if (confirmed) {
      final success = await provider.updateRoomStatus(room.id, status);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  Future<bool> _showConfirmDialog(BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('CONFIRM'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Widget _buildEmptyState(RoomProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hotel, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No rooms found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Try changing your search or filter'
                : 'Click + to add a new room',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}