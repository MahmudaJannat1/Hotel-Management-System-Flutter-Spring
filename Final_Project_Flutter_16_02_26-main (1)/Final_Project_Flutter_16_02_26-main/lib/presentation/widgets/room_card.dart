import 'package:flutter/material.dart';
import 'package:hotel_management_app/data/models/room_model.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;

  const RoomCard({
    Key? key,
    required this.room,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey[300],
                child: room.images.isNotEmpty
                    ? _buildImage(room.images.first)
                    : _buildPlaceholder(),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Number and Type
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
                            SizedBox(height: 4),
                            Text(
                              room.roomType,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(room.price),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
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

                  // Capacity
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'Up to ${room.maxOccupancy} guests',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Amenities (first 3)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: room.amenities.take(3).map((amenity) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 8),

                  // Availability Status
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: room.isAvailable ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        room.isAvailable ? 'Available' : 'Booked',
                        style: TextStyle(
                          color: room.isAvailable ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
  Widget _buildImage(String imagePath) {
    print('🖼️ RoomCard loading: $imagePath');

    // Asset ইমেজ
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      height: 160,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Error loading image: $imagePath');
        print('Error: $error');
        return _buildPlaceholder();
      },
    );
  }

  // প্লেসহোল্ডার ইমেজ
  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}