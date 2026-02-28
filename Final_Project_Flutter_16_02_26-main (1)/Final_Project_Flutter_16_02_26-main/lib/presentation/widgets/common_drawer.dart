import 'package:flutter/material.dart';
import 'package:hotel_management_app/presentation/screens/admin/hr_management_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/inventory_management_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/auth_provider.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/presentation/screens/admin/admin_home_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/room_management_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/user_management_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/booking_management_screen.dart';
import '../screens/admin/payment_management_screen.dart';
import '../screens/admin/reports_screen.dart';

class CommonDrawer extends StatelessWidget {
  final String currentRoute;

  const CommonDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue[50],
        child: ListView(
          padding: EdgeInsets.zero,
          physics: BouncingScrollPhysics(),
          children: [
            _buildHeader(),
            SizedBox(height: 20),

            _buildMenuItem(
              context,
              Icons.dashboard,
              'Dashboard',
              AppRoutes.adminHome,
              isSelected: currentRoute == AppRoutes.adminHome,
              screen: AdminHomeScreen(),
            ),

            _buildMenuItem(
              context,
              Icons.hotel,
              'Room Management',
              AppRoutes.adminRooms,
              isSelected: currentRoute == AppRoutes.adminRooms,
              screen: RoomManagementScreen(),
            ),

            _buildMenuItem(
              context,
              Icons.people,
              'User Management',
              AppRoutes.adminUsers,
              isSelected: currentRoute == AppRoutes.adminUsers,
              screen: UserManagementScreen(),
            ),

            _buildMenuItem(
              context,
              Icons.book_online,
              'Booking Management',
              AppRoutes.adminBookings,
              isSelected: currentRoute == AppRoutes.adminBookings,
              screen: BookingManagementScreen(),
            ),

            _buildMenuItem(
              context,
              Icons.inventory,
              'Inventory',
              AppRoutes.adminInventory,
              isSelected: currentRoute == AppRoutes.adminInventory,
              screen: InventoryManagementScreen(),
            ),

            _buildMenuItem(
              context,
              Icons.assignment_ind,
              'HR Management',
              AppRoutes.adminHr,
              isSelected: currentRoute == AppRoutes.adminHr,
              screen: HrManagementScreen(),
            ),

            _buildMenuItem(
              context,
              Icons.report,
              'Reports',
              AppRoutes.adminReports,
              isSelected: currentRoute == AppRoutes.adminReports,
              screen: ReportsScreen(),
            ),

            _buildMenuItem(
              context,
              Icons.payment,
              'Payments',
              AppRoutes.adminPayments,
              isSelected: currentRoute == AppRoutes.adminPayments,
              screen: PaymentManagementScreen(),
            ),

            _buildMenuItem(
              context,
              Icons.settings,
              'Settings',
              AppRoutes.adminSettings,
              isSelected: currentRoute == AppRoutes.adminSettings,
              screen: SettingsScreen(),
            ),

            Divider(thickness: 1, height: 30),

            _buildLogoutItem(context),
          ],
        ),
      ),
    );
  }

  // 🔥 PREMIUM HEADER
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                "https://media.licdn.com/dms/image/v2/D4E12AQGtggQz8UxzNA/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1682491424878?e=2147483647&v=beta&t=DbIxcVJ-tv4hlwUs6QNEhae3NnDQ2KFyNkUaJqaUU9Q",
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin Panel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Hotel Management System",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title,
      String route, {
        bool isSelected = false,
        Widget? screen,
      }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue[800],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue[900] : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);

          if (isSelected) return;

          if (screen != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          } else {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        dense: true,
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.red),
      title: Text(
        'Logout',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
      ),
      onTap: () => _showLogoutDialog(context),
      dense: true,
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