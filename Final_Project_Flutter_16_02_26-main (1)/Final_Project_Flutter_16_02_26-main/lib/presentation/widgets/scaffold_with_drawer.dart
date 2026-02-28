import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/auth_provider.dart';
import 'package:hotel_management_app/presentation/screens/admin/user_management_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/room_management_screen.dart';

class ScaffoldWithDrawer extends StatelessWidget {
  final String title;
  final Widget body;
  final int selectedIndex; // 0=dashboard, 1=rooms, 2=users, etc

  const ScaffoldWithDrawer({
    Key? key,
    required this.title,
    required this.body,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: Icon(Icons.sync), onPressed: () {}),
        ],
      ),
      drawer: _buildDrawer(context),
      body: body,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 120,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, color: Colors.blue[800]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildDrawerItem(
                Icons.dashboard,
                'Dashboard',
                selectedIndex == 0,
                    () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/admin/home');
                }
            ),
            _buildDrawerItem(
                Icons.hotel,
                'Room Management',
                selectedIndex == 1,
                    () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomManagementScreen(),
                    ),
                  );
                }
            ),
            _buildDrawerItem(
                Icons.people,
                'User Management',
                selectedIndex == 2,
                    () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserManagementScreen(),
                    ),
                  );
                }
            ),
            Divider(thickness: 1, height: 30),
            _buildDrawerItem(
              Icons.logout,
              'Logout',
              false,
                  () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isSelected, VoidCallback onTap, {Color? color}) {
    return Container(
      color: isSelected ? Colors.blue[100] : null,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue[800] : (color ?? Colors.blue[800])),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue[800] : (color ?? Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        dense: true,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
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
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: Text('LOGOUT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}