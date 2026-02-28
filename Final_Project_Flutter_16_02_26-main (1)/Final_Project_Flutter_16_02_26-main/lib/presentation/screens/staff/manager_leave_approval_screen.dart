// lib/presentation/screens/staff/manager_leave_approval_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/data/models/staff_leave_model.dart';

class ManagerLeaveApprovalScreen extends StatefulWidget {
  @override
  _ManagerLeaveApprovalScreenState createState() => _ManagerLeaveApprovalScreenState();
}

class _ManagerLeaveApprovalScreenState extends State<ManagerLeaveApprovalScreen> {
  List<StaffLeave> _pendingLeaves = [];
  List<StaffLeave> _approvedLeaves = [];
  List<StaffLeave> _rejectedLeaves = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllLeaves();
    });
  }

  Future<void> _loadAllLeaves() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<StaffProvider>(context, listen: false);
    final allLeaves = await provider.getAllLeaveApplications();

    setState(() {
      _pendingLeaves = allLeaves.where((l) => l.status == 'Pending').toList();
      _approvedLeaves = allLeaves.where((l) => l.status == 'Approved').toList();
      _rejectedLeaves = allLeaves.where((l) => l.status == 'Rejected').toList();
      _isLoading = false;
    });
  }

  Future<void> _showApprovalDialog(StaffLeave leave) async {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Staff: ${leave.staffName}'),
            Text('Type: ${leave.leaveType}'),
            Text('Days: ${leave.totalDays} (${leave.startDate.day}/${leave.startDate.month} - ${leave.endDate.day}/${leave.endDate.month})'),
            Text('Reason: ${leave.reason}'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Rejection Reason (if rejecting)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _approveLeave(leave.id, reasonController.text.isEmpty ? null : reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('APPROVE'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please provide rejection reason')),
                );
                return;
              }
              Navigator.pop(context);
              await _rejectLeave(leave.id, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('REJECT'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveLeave(int leaveId, String? reason) async {
    final provider = Provider.of<StaffProvider>(context, listen: false);
    final currentUser = provider.currentUser;

    if (currentUser == null) return;

    setState(() => _isLoading = true);

    final success = await provider.approveLeave(leaveId, currentUser.name);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave approved successfully'), backgroundColor: Colors.green),
      );
      _loadAllLeaves();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve leave'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectLeave(int leaveId, String reason) async {
    final provider = Provider.of<StaffProvider>(context, listen: false);
    final currentUser = provider.currentUser;

    if (currentUser == null) return;

    setState(() => _isLoading = true);

    final success = await provider.rejectLeave(leaveId, reason, currentUser.name);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave rejected'), backgroundColor: Colors.orange),
      );
      _loadAllLeaves();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject leave'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    final isManager = provider.currentUser?.role == 'Manager';

    if (!isManager) {
      return Scaffold(
        appBar: AppBar(title: Text('Leave Approval')),
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Leave Management'),
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending (${_pendingLeaves.length})'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadAllLeaves,
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildPendingLeaves(),
            _buildApprovedLeaves(),
            _buildRejectedLeaves(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingLeaves() {
    if (_pendingLeaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green[200]),
            SizedBox(height: 16),
            Text('No pending leave requests'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _pendingLeaves.length,
      itemBuilder: (context, index) {
        final leave = _pendingLeaves[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _showApprovalDialog(leave),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        child: Icon(Icons.pending, color: Colors.orange),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leave.staffName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${leave.leaveType} Leave',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${leave.totalDays} days',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('Reason: ${leave.reason}'),
                  SizedBox(height: 8),
                  Text(
                    '${leave.startDate.day}/${leave.startDate.month} - ${leave.endDate.day}/${leave.endDate.month}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovedLeaves() {
    if (_approvedLeaves.isEmpty) {
      return Center(child: Text('No approved leaves'));
    }

    return ListView.builder(
      itemCount: _approvedLeaves.length,
      itemBuilder: (context, index) {
        final leave = _approvedLeaves[index];
        return ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text(leave.staffName),
          subtitle: Text('${leave.leaveType} - ${leave.totalDays} days'),
          trailing: Text('Approved'),
        );
      },
    );
  }

  Widget _buildRejectedLeaves() {
    if (_rejectedLeaves.isEmpty) {
      return Center(child: Text('No rejected leaves'));
    }

    return ListView.builder(
      itemCount: _rejectedLeaves.length,
      itemBuilder: (context, index) {
        final leave = _rejectedLeaves[index];
        return ListTile(
          leading: Icon(Icons.cancel, color: Colors.red),
          title: Text(leave.staffName),
          subtitle: Text(leave.rejectionReason ?? 'No reason'),
          trailing: Text('Rejected'),
        );
      },
    );
  }
}