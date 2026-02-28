import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/presentation/widgets/staff_drawer.dart';

import '../../../data/models/staff_task_model.dart';

class StaffTaskScreen extends StatefulWidget {
  @override
  _StaffTaskScreenState createState() => _StaffTaskScreenState();
}

class _StaffTaskScreenState extends State<StaffTaskScreen> {
  // Store provider reference safely
  StaffProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe way to get provider reference
    _provider = Provider.of<StaffProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshTasks,
          ),
        ],
      ),
      drawer: StaffDrawer(),
      body: Consumer<StaffProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text('No tasks assigned'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return _buildTaskCard(context, task, provider);
            },
          );
        },
      ),
    );
  }

  void _refreshTasks() {
    if (!mounted) return;
    final provider = Provider.of<StaffProvider>(context, listen: false);
    if (provider.currentUser != null) {
      provider.loadStaffData(provider.currentUser!.id);
    }
  }

  Widget _buildTaskCard(BuildContext context, StaffTask task, StaffProvider provider) {
    Color priorityColor = task.priority == 'High'
        ? Colors.red
        : task.priority == 'Medium'
        ? Colors.orange
        : Colors.green;

    Color statusColor = task.status == 'Completed'
        ? Colors.green
        : task.status == 'In Progress'
        ? Colors.blue
        : Colors.orange;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor.withOpacity(0.1),
          child: Icon(Icons.task, color: priorityColor),
        ),
        title: Text(
          task.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Due: ${_formatDate(task.dueDate)}'),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(task.description),
                SizedBox(height: 16),

                Text(
                  'Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _buildInfoRow('Priority', task.priority, priorityColor),
                _buildInfoRow('Assigned', _formatDate(task.assignedDate), Colors.grey),
                if (task.notes != null && task.notes!.isNotEmpty)
                  _buildInfoRow('Notes', task.notes!, Colors.grey),

                SizedBox(height: 16),

                // Status Update Buttons
                Text(
                  'Update Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusButton(
                      context,
                      'Pending',
                      task.status == 'Pending' ? Colors.orange : Colors.grey,
                      task,
                    ),
                    _buildStatusButton(
                      context,
                      'In Progress',
                      task.status == 'In Progress' ? Colors.blue : Colors.grey,
                      task,
                    ),
                    _buildStatusButton(
                      context,
                      'Completed',
                      task.status == 'Completed' ? Colors.green : Colors.grey,
                      task,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
      BuildContext context,
      String status,
      Color color,
      StaffTask task,
      ) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: task.status == status
              ? null
              : () => _updateTaskStatus(context, task.id, status),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: color),
            ),
          ),
          child: Text(
            status,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _updateTaskStatus(BuildContext context, int taskId, String newStatus) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Update Task Status'),
        content: Text('Mark this task as $newStatus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('UPDATE', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Check if widget is still mounted
    if (!mounted) return;

    // Get fresh provider instance
    final provider = Provider.of<StaffProvider>(context, listen: false);

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updating status...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final success = await provider.updateTaskStatus(taskId, newStatus);

      // Check if widget is still mounted
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task status updated to $newStatus'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update status'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.day}/${date.month}/${date.year}';
  }
}