import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/presentation/screens/guest/room_list_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class RoomSearchScreen extends StatefulWidget {
  @override
  _RoomSearchScreenState createState() => _RoomSearchScreenState();
}

class _RoomSearchScreenState extends State<RoomSearchScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 2;
  String? _selectedRoomType;
  RangeValues _priceRange = RangeValues(0, 10000);
  bool _isLoading = false;

  final List<String> _roomTypes = [
    'Standard',
    'Deluxe',
    'Suite',
    'Family',
    'Executive',
  ];


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
    await provider.loadAvailableRooms();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate!.add(Duration(days: 1));
          }
        } else {
          if (_checkInDate != null && picked.isBefore(_checkInDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Check-out must be after check-in'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            _checkOutDate = picked;
          }
        }
      });
    }
  }

  void _searchRooms() {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select check-in and check-out dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Searching with params:');
    print('Check-in: $_checkInDate');
    print('Check-out: $_checkOutDate');
    print('Guests: $_numberOfGuests');
    print('Room Type: ${_selectedRoomType ?? "Any"}');
    print('Max Price: ${_priceRange.end}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomListScreen(
          checkInDate: _checkInDate!,
          checkOutDate: _checkOutDate!,
          numberOfGuests: _numberOfGuests,
          roomType: _selectedRoomType,
          maxPrice: _priceRange.end,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 230,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                enlargeCenterPage: false,
              ),
              items: [
                'assets/images/room4.jpg',
                'assets/images/r3.jpg',
                'assets/images/r1.jpg',
                'assets/images/r2.jpg',
              ].map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.hotel,
                              size: 50,
                              color: Colors.grey[500],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20),

          // Welcome Text
          Text(
            'Find Your Perfect Stay',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Search available rooms for your dates',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),

          // Search Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Criteria',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Check-in Date
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Check-in Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _checkInDate == null
                            ? 'Select date'
                            : '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}',
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Check-out Date
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Check-out Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _checkOutDate == null
                            ? 'Select date'
                            : '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}',
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Number of Guests
                  Row(
                    children: [
                      Expanded(
                        child: Text('Number of Guests'),
                      ),
                      Container(
                        width: 120,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: _numberOfGuests > 1
                                  ? () => setState(() => _numberOfGuests--)
                                  : null,
                            ),
                            Expanded(
                              child: Text(
                                '$_numberOfGuests',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: _numberOfGuests < 6
                                  ? () => setState(() => _numberOfGuests++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Room Type
                  DropdownButtonFormField<String>(
                    value: _selectedRoomType,
                    decoration: InputDecoration(
                      labelText: 'Room Type (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.hotel),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Any Type'),
                      ),
                      ..._roomTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRoomType = value);
                    },
                  ),
                  SizedBox(height: 12),

                  // Price Range
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Range: ৳${_priceRange.start.round()} - ৳${_priceRange.end.round()}',
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 20000,
                        divisions: 20,
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _searchRooms,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'SEARCH ROOMS',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}