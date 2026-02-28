import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/hr_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/presentation/screens/admin/employee_list_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/attendance_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/leave_management_screen.dart';
import '../../../data/models/attendance_model.dart';
import 'add_edit_employee_screen.dart';

class HrManagementScreen extends StatefulWidget {
  @override
  _HrManagementScreenState createState() => _HrManagementScreenState();
}

class _HrManagementScreenState extends State<HrManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  final int _hotelId = 1;
  final Map<int, Map<String, dynamic>> _attendanceMarks = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final hrProvider = Provider.of<HrProvider>(context, listen: false);

    await Future.wait([
      hrProvider.loadAllEmployees(_hotelId),
      hrProvider.loadAttendanceByDate(_selectedDate, _hotelId),
    ]);

    if (mounted) {
      _initializeAttendanceMarks(hrProvider);
    }
  }

  void _initializeAttendanceMarks(HrProvider provider) {
    for (var employee in provider.employees) {
      final existingAttendance = provider.attendances.firstWhere(
            (a) => a.employeeId == employee.id,
        orElse: () => Attendance(
          id: 0,
          employeeId: employee.id,
          employeeName: employee.fullName,
          date: _selectedDate,
          status: 'ABSENT',
          isApproved: false,
        ),
      );

      _attendanceMarks[employee.id] = {
        'status': existingAttendance.status,
        'checkIn': existingAttendance.checkInTime,
        'checkOut': existingAttendance.checkOutTime,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminHr),
      appBar: AppBar(
        title: Text('HR Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<HrProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.employees.isEmpty) {
            return LoadingIndicator(message: 'Loading HR data...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadData,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        'Total Employees',
                        '${provider.totalEmployees}',
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Active',
                        '${provider.activeEmployees}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'On Leave',
                        '${provider.onLeaveEmployees}',
                        Icons.beach_access,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Present Today',
                        '${provider.presentToday}',
                        Icons.today,
                        Colors.purple,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildActionChip(
                        Icons.person_add,
                        'Add Employee',
                            () => _navigateToEmployeeForm(context),
                      ),
                      _buildActionChip(
                        Icons.fingerprint,
                        'Mark Attendance',
                            () => _navigateToAttendance(context),
                      ),
                      _buildActionChip(
                        Icons.beach_access,
                        'Leave Requests',
                            () => _navigateToLeaveManagement(context),
                      ),
                      _buildActionChip(
                        Icons.list,
                        'Employee List',
                            () => _navigateToEmployeeList(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Today\'s Attendance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _buildAttendanceList(provider),

                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
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
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
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

  Widget _buildAttendanceList(HrProvider provider) {
    if (provider.attendances.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No attendance marked today',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: provider.attendances.length > 5 ? 5 : provider.attendances.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          final attendance = provider.attendances[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(attendance.status).withOpacity(0.1),
              child: Icon(
                _getStatusIcon(attendance.status),
                color: _getStatusColor(attendance.status),
                size: 20,
              ),
            ),
            title: Text(
              attendance.employeeName,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(attendance.department ?? ''),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(attendance.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                attendance.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(attendance.status),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PRESENT': return Colors.green;
      case 'ABSENT': return Colors.red;
      case 'LATE': return Colors.orange;
      case 'HALF_DAY': return Colors.amber;
      case 'OVERTIME': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PRESENT': return Icons.check_circle;
      case 'ABSENT': return Icons.cancel;
      case 'LATE': return Icons.access_time;
      case 'HALF_DAY': return Icons.wb_twilight;
      case 'OVERTIME': return Icons.timer;
      default: return Icons.help;
    }
  }

  void _navigateToEmployeeForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditEmployeeScreen(),
      ),
    ).then((_) {
      if (mounted) _loadData();
    });
  }

  void _navigateToAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceScreen(),
      ),
    ).then((_) {
      if (mounted) _loadData();
    });
  }

  void _navigateToLeaveManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaveManagementScreen(),
      ),
    ).then((_) {
      if (mounted) _loadData();
    });
  }

  void _navigateToEmployeeList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeListScreen(),
      ),
    ).then((_) {
      if (mounted) _loadData();
    });
  }
}