// lib/presentation/screens/staff/manager_tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/presentation/screens/staff/assign_task_screen.dart';

import '../../../data/models/staff_task_model.dart';

class ManagerTasksScreen extends StatefulWidget {
  @override
  _ManagerTasksScreenState createState() => _ManagerTasksScreenState();
}

class _ManagerTasksScreenState extends State<ManagerTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<StaffProvider>(context, listen: false);
    await provider.loadAllTasks();
    setState(() {
      _stats = provider.getTaskStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    final isManager = provider.currentUser?.role == 'Manager';

    if (!isManager) {
      return Scaffold(
        appBar: AppBar(title: Text('Task Management')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Only managers can access this section'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'All Tasks'),
            Tab(text: 'By Staff'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssignTaskScreen()),
              );
              if (result == true) {
                _loadData();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(provider),
          _buildAllTasksTab(provider),
          _buildByStaffTab(provider),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(StaffProvider provider) {
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 Stats Cards
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width > 600 ? 3 : 2,   // 📱 Mobile = 2, Tablet = 3
              childAspectRatio: 1.1,                 // 🔥 কমাও (আগে ছিল 1.5)
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final statsList = [
                _buildStatCard('Total Tasks', _stats['total'] ?? 0, Icons.task, Colors.blue),
                _buildStatCard('Pending', _stats['pending'] ?? 0, Icons.pending, Colors.orange),
                _buildStatCard('In Progress', _stats['inProgress'] ?? 0, Icons.hourglass_empty, Colors.purple),
                _buildStatCard('Completed', _stats['completed'] ?? 0, Icons.check_circle, Colors.green),
                _buildStatCard('Overdue', _stats['overdue'] ?? 0, Icons.warning, Colors.red),
                _buildStatCard('High Priority', _stats['highPriority'] ?? 0, Icons.priority_high, Colors.red),
              ];
              return statsList[index];
            },
          ),

          SizedBox(height: 24),

          /// 🔹 Recent Tasks
          Text(
            'Recent Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          ...provider.allTasks
              .take(5)
              .map((task) => _buildTaskListItem(task)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color) {
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
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(label, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTasksTab(StaffProvider provider) {
    if (provider.allTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No tasks assigned yet'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AssignTaskScreen()),
                );
                if (result == true) {
                  _loadData();
                }
              },
              child: Text('Assign First Task'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.allTasks.length,
      itemBuilder: (context, index) {
        final task = provider.allTasks[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: task.priorityColor.withOpacity(0.1),
              child: Icon(Icons.task, color: task.priorityColor, size: 20),
            ),
            title: Text(task.title),
            subtitle: Text('${task.staffName} • ${task.status}'),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: task.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.status,
                style: TextStyle(fontSize: 12, color: task.statusColor),
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildByStaffTab(StaffProvider provider) {
    // Group tasks by staff
    Map<int, List<StaffTask>> tasksByStaff = {};
    for (var task in provider.allTasks) {
      tasksByStaff.putIfAbsent(task.staffId, () => []).add(task);
    }

    if (tasksByStaff.isEmpty) {
      return Center(child: Text('No tasks assigned'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tasksByStaff.length,
      itemBuilder: (context, index) {
        final staffId = tasksByStaff.keys.elementAt(index);
        final staffTasks = tasksByStaff[staffId]!;
        final staffName = staffTasks.first.staffName;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(staffName[0]),
            ),
            title: Text(staffName),
            subtitle: Text('${staffTasks.length} tasks • ${staffTasks.where((t) => t.status == 'Completed').length} completed'),
            children: staffTasks.map((task) => ListTile(
              title: Text(task.title),
              subtitle: Text('Due: ${task.dueDate?.day}/${task.dueDate?.month}'),
              trailing: Chip(
                label: Text(task.status),
                backgroundColor: task.statusColor.withOpacity(0.1),
                labelStyle: TextStyle(fontSize: 10, color: task.statusColor),
              ),
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTaskListItem(StaffTask task) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: task.priorityColor.withOpacity(0.1),
          child: Icon(Icons.task, color: task.priorityColor, size: 18),
        ),
        title: Text(task.title, style: TextStyle(fontSize: 14)),
        subtitle: Text('${task.staffName} • ${task.status}'),
        trailing: task.isOverdue
            ? Icon(Icons.warning, color: Colors.red, size: 18)
            : null,
      ),
    );
  }
}