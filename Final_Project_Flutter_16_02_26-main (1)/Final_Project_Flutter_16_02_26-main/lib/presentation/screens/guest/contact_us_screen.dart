import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _contactMethods = [
    {
      'icon': Icons.phone,
      'title': 'Phone',
      'subtitle': '+880 1234-567890',
      'color': Colors.green,
      'action': 'tel:+8801234567890',
    },
    {
      'icon': Icons.email,
      'title': 'Email',
      'subtitle': 'info@sunrisegrand.com',
      'color': Colors.red,
      'action': 'mailto:info@sunrisegrand.com',
    },
    {
      'icon': Icons.chat,
      'title': 'WhatsApp',
      'subtitle': '+880 1987-654321',
      'color': Colors.green,
      'action': 'https://wa.me/8801987654321',
    },
    {
      'icon': Icons.location_on,
      'title': 'Address',
      'subtitle': '123 Hotel Street, Gulshan, Dhaka',
      'color': Colors.blue,
      'action': 'https://maps.google.com/?q=Gulshan,Dhaka',
    },
    {
      'icon': Icons.language,
      'title': 'Website',
      'subtitle': 'www.sunrisegrand.com',
      'color': Colors.purple,
      'action': 'https://www.sunrisegrand.com',
    },
    {
      'icon': Icons.facebook,
      'title': 'Facebook',
      'subtitle': '@sunrisegrand',
      'color': Colors.blue[800],
      'action': 'https://facebook.com/sunrisegrand',
    },
    {
      'icon': Icons.camera_alt,
      'title': 'Instagram',
      'subtitle': '@sunrisegrand',
      'color': Colors.pink,
      'action': 'https://instagram.com/sunrisegrand',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Get in Touch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We\'re here to help you 24/7',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),

          // Contact Methods Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _contactMethods.length,
            itemBuilder: (context, index) {
              final method = _contactMethods[index];
              return _buildContactCard(method);
            },
          ),
          SizedBox(height: 24),

          // Quick Contact Form
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
                    'Send us a message',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 12),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.message),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Message sent successfully'),
                            backgroundColor: Colors.green,
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
                      child: Text('SEND MESSAGE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Emergency Contact
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 30,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Call our 24/7 helpline',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse('tel:+8801234567890');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('CALL NOW'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> method) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(method['action']);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: method['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  method['icon'],
                  color: method['color'],
                  size: 28,
                ),
              ),
              SizedBox(height: 8),
              Text(
                method['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                method['subtitle'],
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}