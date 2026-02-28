import 'package:flutter/material.dart';
import 'package:hotel_management_app/presentation/screens/admin/room_management_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/user_management_screen.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/auth_provider.dart';
import 'package:hotel_management_app/providers/dashboard_provider.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

import '../../../core/routes/app_routes.dart';
import '../../widgets/common_drawer.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    await dashboardProvider.loadDashboardSummary();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: CommonDrawer(currentRoute: AppRoutes.adminHome),
      body: _buildDashboard(),
    );
  }

  void _showLogoutDialog() {
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

  Widget _buildDashboard() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !_isInitialized) {
          return LoadingIndicator(message: 'Loading dashboard...');
        }

        if (provider.error != null) {
          return ErrorWidgetWithRetry(
            message: provider.error!,
            onRetry: _loadDashboardData,
          );
        }

        final data = provider.dashboardData ?? {};

        return RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard(
                      'Total Revenue',
                      CurrencyFormatter.format(data['todayRevenue'] ?? 0),
                      Icons.monetization_on,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Occupancy',
                      '${data['occupancyRate']?.toStringAsFixed(1) ?? '0.0'}%',
                      Icons.hotel,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Check-ins',
                      '${data['todayCheckIns'] ?? 0}',
                      Icons.login,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Check-outs',
                      '${data['todayCheckOuts'] ?? 0}',
                      Icons.logout,
                      Colors.purple,
                    ),
                  ],
                ),
                SizedBox(height: 24),

                Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                _buildRecentActivityList(),

                SizedBox(height: 24),

                Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                _buildQuickActions(),

                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Flexible(
              child: Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

// Recent Activity Section - Mock Data সরিয়ে Real Data দেখাবেন

  Widget _buildRecentActivityList() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final activities = provider.recentActivities; // Real data from API


        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActivityColor(activity['type']).withOpacity(0.1),
                  child: Icon(
                    _getActivityIcon(activity['type']),
                    color: _getActivityColor(activity['type']),
                    size: 20,
                  ),
                ),
                title: Text(
                  activity['title'] ?? 'New activity',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  activity['description'] ?? '',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _getTimeAgo(activity['timestamp']),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                dense: true,
              );
            },
          ),
        );
        if (activities.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No recent activities',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

      },
    );

  }

// Helper methods for activity UI
  Color _getActivityColor(String? type) {
    switch (type) {
      case 'BOOKING': return Colors.blue;
      case 'CHECK_IN': return Colors.green;
      case 'CHECK_OUT': return Colors.orange;
      case 'PAYMENT': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'BOOKING': return Icons.book_online;
      case 'CHECK_IN': return Icons.login;
      case 'CHECK_OUT': return Icons.logout;
      case 'PAYMENT': return Icons.payment;
      default: return Icons.notifications;
    }
  }

  String _getTimeAgo(String? timestamp) {
    if (timestamp == null) return 'Just now';
    // Parse timestamp and return "x min ago", "x hours ago" etc
    return '10 min ago'; // Temporary
  }
  Widget _buildQuickActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionChip(Icons.person_add, 'Add User', () {}),
        _buildActionChip(Icons.hotel, 'Add Room', () {}),
        _buildActionChip(Icons.book_online, 'New Booking', () {}),
        _buildActionChip(Icons.report, 'Reports', () {}),
        _buildActionChip(Icons.inventory, 'Inventory', () {}),
        _buildActionChip(Icons.settings, 'Settings', () {}),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: Colors.grey[100],
    );
  }
}