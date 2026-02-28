import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/presentation/widgets/staff_drawer.dart';

class StaffHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Dashboard'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: StaffDrawer(),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        user?.name[0] ?? 'S',
                        style: TextStyle(fontSize: 30, color: Colors.blue[800]),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            user?.name ?? 'Staff',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.role ?? '',
                            style: TextStyle(color: Colors.blue[800]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Stats Cards
            Text(
              'Today\'s Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Tasks',
                    provider.tasks.length.toString(),
                    Icons.task,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pending',
                    provider.tasks.where((t) => t.status == 'Pending').length.toString(),
                    Icons.pending,
                    Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Completed',
                    provider.tasks.where((t) => t.status == 'Completed').length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Attendance',
                    provider.attendances.isNotEmpty ? 'Marked' : 'Not yet',
                    Icons.access_time,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Recent Tasks
            Text(
              'Recent Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            provider.tasks.isEmpty
                ? Center(child: Text('No tasks assigned'))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: provider.tasks.length > 3 ? 3 : provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: task.priority == 'High'
                          ? Colors.red[100]
                          : task.priority == 'Medium'
                          ? Colors.orange[100]
                          : Colors.green[100],
                      child: Icon(
                        Icons.task,
                        color: task.priority == 'High'
                            ? Colors.red
                            : task.priority == 'Medium'
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                    title: Text(task.title),
                    subtitle: Text(task.description),
                    trailing: Chip(
                      label: Text(task.status),
                      backgroundColor: task.status == 'Completed'
                          ? Colors.green[100]
                          : task.status == 'In Progress'
                          ? Colors.blue[100]
                          : Colors.orange[100],
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

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}