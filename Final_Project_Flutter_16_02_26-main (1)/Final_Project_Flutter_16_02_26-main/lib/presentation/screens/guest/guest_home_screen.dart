import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/presentation/screens/guest/room_search_screen.dart';
import 'package:hotel_management_app/presentation/screens/guest/room_list_screen.dart';
import 'package:hotel_management_app/presentation/screens/guest/my_bookings_screen.dart';
import 'package:hotel_management_app/presentation/screens/guest/user_profile_screen.dart';

import '../auth/login_screen.dart';

class GuestHomeScreen extends StatefulWidget {
  @override
  _GuestHomeScreenState createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RoomSearchScreen(),
      RoomListScreen(),
      MyBookingsScreen(),
      UserProfileScreen(),
    ];
  }

  // ✅ Logout Dialog function
  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Guest logout
              final guestProvider = Provider.of<GuestProvider>(context, listen: false);
              await guestProvider.logout();

              // Navigate to Admin Login Screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()), // ✅ Admin Login
                    (route) => false,
              );
            },
            child: Text('LOGOUT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuestProvider>(context);

    return Scaffold(
      // ✅ শুধু home screen (index 0) এ AppBar দেখাবে
      appBar: _selectedIndex == 0
          ? AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 🟢 Login Button - Admin Login এ নিয়ে যাবে
          if (!provider.isLoggedIn)
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () {
                // ✅ Admin Login Screen এ নিয়ে যান
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Admin Login
                );
              },
              tooltip: 'Admin Login',
            ),

          // 🔴 Logout Button (visible when logged in)
          if (provider.isLoggedIn)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
              tooltip: 'Logout',
            ),
        ],
      )
          : null, // অন্য screen এ AppBar দেখাবে না

      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}