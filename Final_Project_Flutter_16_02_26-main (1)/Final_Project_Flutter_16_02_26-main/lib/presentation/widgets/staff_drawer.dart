import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/presentation/screens/staff/staff_home_screen.dart';
import 'package:hotel_management_app/presentation/screens/staff/staff_task_screen.dart';

import 'package:hotel_management_app/presentation/screens/staff/staff_profile_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/staff/manager_tasks_screen.dart';
import '../screens/staff/staff_attendance_screen.dart';
import '../screens/staff/staff_leave_screen.dart';
import '../screens/staff/staff_schedule_screen.dart';

class StaffDrawer extends StatelessWidget {
  const StaffDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    final user = provider.currentUser;

    return Drawer(
      child: Container(
        color: Colors.blue[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.name[0] ?? 'S',
                      style: TextStyle(fontSize: 30, color: Colors.blue[800]),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    user?.name ?? 'Staff',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    user?.role ?? '',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            // Menu Items
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.blue[800]),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StaffHomeScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.task, color: Colors.blue[800]),
              title: Text('My Tasks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StaffTaskScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.event_note, color: Colors.blue[800]),
              title: Text('Leave'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StaffLeaveScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: Colors.blue[800]),
              title: Text('Schedule'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StaffScheduleScreen()),
                );
              },
            ),            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.blue[800]),
              title: Text('Attendance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StaffAttendanceScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue[800]),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StaffProfileScreen()),
                );
              },
            ),
            // In staff_drawer.dart, add this after existing items

            if (provider.currentUser?.role == 'Manager')
              ListTile(
                leading: Icon(Icons.assignment, color: Colors.blue[800]),
                title: Text('Task Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManagerTasksScreen()),
                  );
                },
              ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () async {
                final provider = Provider.of<StaffProvider>(context, listen: false);
                await provider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}