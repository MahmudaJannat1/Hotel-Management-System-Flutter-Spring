import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/presentation/widgets/staff_drawer.dart';

import '../../../data/models/staff_attendance_model.dart';

class StaffAttendanceScreen extends StatefulWidget {
  @override
  _StaffAttendanceScreenState createState() => _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends State<StaffAttendanceScreen> {
  bool _isLoading = false;
  StaffAttendance? _todayAttendance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayAttendance();
    });
  }

  Future<void> _loadTodayAttendance() async {
    final provider = Provider.of<StaffProvider>(context, listen: false);
    if (provider.currentUser != null) {
      final attendance = await provider.getTodayAttendance(provider.currentUser!.id);
      setState(() {
        _todayAttendance = attendance;
      });
    }
  }

  Future<void> _checkIn() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<StaffProvider>(context, listen: false);
    final user = provider.currentUser!;

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final attendance = StaffAttendance(
      id: 0,
      staffId: user.id,
      staffName: user.name,
      date: now,
      status: 'Present',
      checkInTime: timeStr,
      checkOutTime: null,
      notes: null,
    );

    final success = await provider.markAttendance(attendance);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-in successful at $timeStr'),
          backgroundColor: Colors.green,
        ),
      );
      _loadTodayAttendance();
    }
  }

  Future<void> _checkOut() async {
    if (_todayAttendance == null) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<StaffProvider>(context, listen: false);
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final success = await provider.updateCheckOut(_todayAttendance!.id, timeStr);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-out successful at $timeStr'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadTodayAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      drawer: StaffDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Today's Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      _todayAttendance == null
                          ? Icons.access_time
                          : _todayAttendance!.checkOutTime == null
                          ? Icons.login
                          : Icons.check_circle,
                      size: 60,
                      color: _todayAttendance == null
                          ? Colors.grey
                          : _todayAttendance!.checkOutTime == null
                          ? Colors.green
                          : Colors.blue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _todayAttendance == null
                          ? 'Not Checked In'
                          : _todayAttendance!.checkOutTime == null
                          ? 'Checked In'
                          : 'Completed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_todayAttendance != null) ...[
                      SizedBox(height: 8),
                      Text(
                        'Date: ${_todayAttendance!.date.day}/${_todayAttendance!.date.month}/${_todayAttendance!.date.year}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Check-in/Check-out Buttons
            if (_todayAttendance == null)
              _buildActionButton(
                'CHECK IN',
                Icons.login,
                Colors.green,
                _checkIn,
              )
            else if (_todayAttendance!.checkOutTime == null)
              _buildActionButton(
                'CHECK OUT',
                Icons.logout,
                Colors.orange,
                _checkOut,
              ),

            SizedBox(height: 20),

            // Attendance History
            Text(
              'Attendance History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            provider.attendances.isEmpty
                ? Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No attendance records'),
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: provider.attendances.length > 5
                  ? 5
                  : provider.attendances.length,
              itemBuilder: (context, index) {
                final att = provider.attendances[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: att.status == 'Present'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      child: Icon(
                        att.status == 'Present'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: att.status == 'Present'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(
                      '${att.date.day}/${att.date.month}/${att.date.year}',
                    ),
                    subtitle: Text(
                      'In: ${att.checkInTime ?? '--'}  |  Out: ${att.checkOutTime ?? '--'}',
                    ),
                    trailing: Text(
                      att.workingHours,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}