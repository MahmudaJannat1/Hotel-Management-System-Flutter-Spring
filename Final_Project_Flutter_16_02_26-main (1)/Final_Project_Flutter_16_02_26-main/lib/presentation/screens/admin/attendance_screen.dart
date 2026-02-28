import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/hr_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import '../../../data/models/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  final int _hotelId = 1;
  Map<int, Map<String, dynamic>> _attendanceMarks = {};

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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      if (mounted) _loadData();
    }
  }

  Future<void> _markAttendance(int employeeId, String status) async {
    if (!mounted) return;
    final hrProvider = Provider.of<HrProvider>(context, listen: false);

    Map<String, dynamic> attendanceData = {
      'employeeId': employeeId,
      'date': _selectedDate.toIso8601String().split('T')[0],
      'status': status,
      'checkInTime': status == 'PRESENT' ? '09:00' : null,
      'checkOutTime': status == 'PRESENT' ? '18:00' : null,
      'remarks': '',
    };

    final success = await hrProvider.markAttendance(attendanceData);

    if (success && mounted) {
      setState(() {
        _attendanceMarks[employeeId] = {
          ..._attendanceMarks[employeeId]!,
          'status': status,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance marked successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getStatusCount(String status) {
    final count = _attendanceMarks.values
        .where((m) => m['status'] == status)
        .length;
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(  // 🔥 Back Button
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // HR Dashboard এ ফিরে যাবে
          },
        ),
        title: Text('Attendance'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<HrProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.employees.isEmpty) {
            return LoadingIndicator(message: 'Loading attendance...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadData,
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// LEFT SIDE — DATE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 16,   // slightly reduced for safety
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    /// RIGHT SIDE — STATUS CHIPS
                    Expanded(   // 🔥 This fixes overflow
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatusChip(
                                'PRESENT', Colors.green, _getStatusCount('PRESENT')),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                                'ABSENT', Colors.red, _getStatusCount('ABSENT')),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                                'LATE', Colors.orange, _getStatusCount('LATE')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.employees.isEmpty
                    ? Center(child: Text('No employees found'))
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: provider.employees.length,
                  itemBuilder: (context, index) {
                    final employee = provider.employees[index];
                    final attendance = _attendanceMarks[employee.id];

                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                employee.fullName.isNotEmpty ? employee.fullName[0] : '?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.fullName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    employee.position,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusDropdown(employee.id, attendance?['status'] ?? 'ABSENT'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color, String count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            '$status: $count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(int employeeId, String currentStatus) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: currentStatus,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down),
        items: ['PRESENT', 'ABSENT', 'LATE', 'HALF_DAY', 'OVERTIME']
            .map((status) => DropdownMenuItem(
          value: status,
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: _getStatusColor(status),
            ),
          ),
        ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            _markAttendance(employeeId, value);
          }
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
}