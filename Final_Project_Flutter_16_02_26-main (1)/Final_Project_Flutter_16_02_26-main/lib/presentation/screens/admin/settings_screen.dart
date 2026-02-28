import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/settings_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';

import '../../../data/models/settings_model.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final int _hotelId = 1;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    if (!mounted) return;
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    await provider.loadAllSettings(_hotelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminSettings),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: [
            Tab(text: 'Hotel', icon: Icon(Icons.hotel)),
            Tab(text: 'System', icon: Icon(Icons.settings)),
            Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
            Tab(text: 'Backup', icon: Icon(Icons.backup)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.hotelSettings == null) {
            return LoadingIndicator(message: 'Loading settings...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadSettings,
            );
          }

          return IndexedStack(
            index: _selectedTab,
            children: [
              _buildHotelSettings(provider),
              _buildSystemSettings(provider),
              _buildNotificationSettings(provider),
              _buildBackupSettings(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHotelSettings(SettingsProvider provider) {
    final settings = provider.hotelSettings;
    if (settings == null) return Center(child: Text('No hotel settings'));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hotel Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Hotel Name', settings.hotelName),
                  if (settings.address != null)
                    _buildInfoRow('Address', settings.address!),
                  if (settings.city != null)
                    _buildInfoRow('City', settings.city!),
                  if (settings.country != null)
                    _buildInfoRow('Country', settings.country!),
                  if (settings.phone != null)
                    _buildInfoRow('Phone', settings.phone!),
                  if (settings.email != null)
                    _buildInfoRow('Email', settings.email!),
                  if (settings.website != null)
                    _buildInfoRow('Website', settings.website!),
                  if (settings.starRating != null)
                    _buildInfoRow('Star Rating', '${settings.starRating} ★'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Check-in Time', settings.checkInTime ?? '14:00'),
                  _buildInfoRow('Check-out Time', settings.checkOutTime ?? '12:00'),
                  _buildInfoRow('Currency', settings.currency ?? 'BDT'),
                  _buildInfoRow('Tax Rate', '${settings.taxRate ?? 15}%'),
                  _buildInfoRow('Timezone', settings.timezone ?? 'Asia/Dhaka'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showEditHotelDialog(context, settings),
              icon: Icon(Icons.edit),
              label: Text('Edit Hotel Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettings(SettingsProvider provider) {
    final settings = provider.systemSettings;
    if (settings == null) return Center(child: Text('No system settings'));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Configuration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Maintenance Mode',
                      settings.maintenanceMode ? 'Enabled' : 'Disabled'),
                  _buildInfoRow('Allow Registration',
                      settings.allowRegistration ? 'Yes' : 'No'),
                  _buildInfoRow('Email Notifications',
                      settings.emailNotifications ? 'Enabled' : 'Disabled'),
                  _buildInfoRow('SMS Notifications',
                      settings.smsNotifications ? 'Enabled' : 'Disabled'),
                  _buildInfoRow('Session Timeout', '${settings.sessionTimeout} minutes'),
                  _buildInfoRow('Max Login Attempts', '${settings.maxLoginAttempts}'),
                  _buildInfoRow('Date Format', settings.dateFormat),
                  _buildInfoRow('Time Format', settings.timeFormat),
                  _buildInfoRow('Language', settings.language.toUpperCase()),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showEditSystemDialog(context, settings),
              icon: Icon(Icons.edit),
              label: Text('Edit System Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(SettingsProvider provider) {
    final settings = provider.notificationSettings;
    if (settings == null) return Center(child: Text('No notification settings'));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildSwitchRow(
                    'Booking Confirmations',
                    settings.bookingConfirmations,
                        (value) => _updateNotificationSetting(
                      provider,
                      'bookingConfirmations',
                      value,
                    ),
                  ),
                  _buildSwitchRow(
                    'Check-in Reminders',
                    settings.checkInReminders,
                        (value) => _updateNotificationSetting(
                      provider,
                      'checkInReminders',
                      value,
                    ),
                  ),
                  _buildSwitchRow(
                    'Check-out Reminders',
                    settings.checkOutReminders,
                        (value) => _updateNotificationSetting(
                      provider,
                      'checkOutReminders',
                      value,
                    ),
                  ),
                  _buildSwitchRow(
                    'Payment Receipts',
                    settings.paymentReceipts,
                        (value) => _updateNotificationSetting(
                      provider,
                      'paymentReceipts',
                      value,
                    ),
                  ),
                  _buildSwitchRow(
                    'Low Stock Alerts',
                    settings.lowStockAlerts,
                        (value) => _updateNotificationSetting(
                      provider,
                      'lowStockAlerts',
                      value,
                    ),
                  ),
                  _buildSwitchRow(
                    'Task Assignments',
                    settings.taskAssignments,
                        (value) => _updateNotificationSetting(
                      provider,
                      'taskAssignments',
                      value,
                    ),
                  ),
                  _buildSwitchRow(
                    'Leave Requests',
                    settings.leaveRequests,
                        (value) => _updateNotificationSetting(
                      provider,
                      'leaveRequests',
                      value,
                    ),
                  ),
                  _buildSwitchRow(
                    'Payroll Notifications',
                    settings.payrollNotifications,
                        (value) => _updateNotificationSetting(
                      provider,
                      'payrollNotifications',
                      value,
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

  Widget _buildBackupSettings(SettingsProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backup & Restore',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  if (provider.lastBackupUrl != null) ...[
                    _buildInfoRow('Last Backup', provider.lastBackupUrl!),
                    SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _createBackup(context, provider),
                          icon: Icon(Icons.backup),
                          label: Text('Create Backup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showRestoreDialog(context, provider),
                          icon: Icon(Icons.restore),
                          label: Text('Restore'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Logs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _viewLogs(context, provider),
                    icon: Icon(Icons.list),
                    label: Text('View System Logs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      minimumSize: Size(double.infinity, 45),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[800],
          ),
        ],
      ),
    );
  }

  Future<void> _updateNotificationSetting(
      SettingsProvider provider,
      String key,
      bool value,
      ) async {
    final current = provider.notificationSettings;
    if (current == null) return;

    final updatedSettings = {
      'bookingConfirmations': key == 'bookingConfirmations' ? value : current.bookingConfirmations,
      'checkInReminders': key == 'checkInReminders' ? value : current.checkInReminders,
      'checkOutReminders': key == 'checkOutReminders' ? value : current.checkOutReminders,
      'paymentReceipts': key == 'paymentReceipts' ? value : current.paymentReceipts,
      'lowStockAlerts': key == 'lowStockAlerts' ? value : current.lowStockAlerts,
      'taskAssignments': key == 'taskAssignments' ? value : current.taskAssignments,
      'leaveRequests': key == 'leaveRequests' ? value : current.leaveRequests,
      'payrollNotifications': key == 'payrollNotifications' ? value : current.payrollNotifications,
    };

    await provider.updateNotificationSettings(_hotelId, updatedSettings);
  }

  Future<void> _showEditHotelDialog(BuildContext context, HotelSettings settings) async {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  Future<void> _showEditSystemDialog(BuildContext context, SystemSettings settings) async {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  Future<void> _createBackup(BuildContext context, SettingsProvider provider) async {
    final success = await provider.createBackup();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showRestoreDialog(BuildContext context, SettingsProvider provider) async {
    // TODO: Implement restore dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restore feature coming soon')),
    );
  }

  Future<void> _viewLogs(BuildContext context, SettingsProvider provider) async {
    // TODO: Implement logs view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logs feature coming soon')),
    );
  }
}