import 'package:flutter/material.dart';

class HotelInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/hotel_banner.jpg',
              height: 200,
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
            ),
          ),
          SizedBox(height: 20),

          // Hotel Name
          Text(
            'Sunrise Grand Hotel',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),

          // Rating
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 20,
                  color: Colors.amber,
                );
              }),
              SizedBox(width: 8),
              Text(
                '5.0 (1,234 reviews)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Description
          Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sunrise Grand Hotel is a luxurious 5-star hotel located in the heart of Dhaka. '
                'We offer world-class amenities, spacious rooms, and exceptional service to make '
                'your stay memorable. Our hotel features a rooftop pool, fitness center, spa, '
                'and multiple dining options.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 20),

          // Location
          _buildInfoSection(
            'Location',
            Icons.location_on,
            '123 Hotel Street, Gulshan, Dhaka 1212, Bangladesh',
          ),
          SizedBox(height: 16),

          // Contact
          _buildInfoSection(
            'Contact',
            Icons.phone,
            '+880 1234-567890\n+880 1987-654321',
          ),
          SizedBox(height: 16),

          // Email
          _buildInfoSection(
            'Email',
            Icons.email,
            'info@sunrisegrand.com\nreservations@sunrisegrand.com',
          ),
          SizedBox(height: 16),

          // Amenities
          Text(
            'Amenities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmenityChip(Icons.wifi, 'Free WiFi'),
              _buildAmenityChip(Icons.local_parking, 'Free Parking'),
              _buildAmenityChip(Icons.fitness_center, 'Gym'),
              _buildAmenityChip(Icons.pool, 'Swimming Pool'),
              _buildAmenityChip(Icons.restaurant, 'Restaurant'),
              _buildAmenityChip(Icons.local_bar, 'Bar'),
              _buildAmenityChip(Icons.spa, 'Spa'),
              _buildAmenityChip(Icons.room_service, 'Room Service'),
              _buildAmenityChip(Icons.ac_unit, 'Air Conditioning'),
              _buildAmenityChip(Icons.kitchen, 'Mini Bar'),
            ],
          ),
          SizedBox(height: 20),

          // Policies
          Text(
            'Policies',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
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
                    'Cancellation',
                    'Free cancellation up to 24 hours before check-in',
                  ),
                  Divider(),
                  _buildPolicyRow(
                    Icons.pets,
                    'Pets',
                    'Pets are not allowed',
                  ),
                  Divider(),
                  _buildPolicyRow(
                    Icons.smoking_rooms,
                    'Smoking',
                    'Non-smoking rooms available',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Map Preview
          Text(
            'Find Us',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 50,
                    color: Colors.grey[500],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Map View',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gulshan, Dhaka',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  Widget _buildInfoSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.blue[800]),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                content,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue[800]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[800],
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