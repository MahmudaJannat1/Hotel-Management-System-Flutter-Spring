import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/hr_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/data/models/leave_model.dart';

class LeaveManagementScreen extends StatefulWidget {
  @override
  _LeaveManagementScreenState createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  final int _hotelId = 1;
  String _selectedFilter = 'pending';

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
      hrProvider.loadAllLeaves(_hotelId),
    ]);
  }

  List<Leave> _getFilteredLeaves(HrProvider provider) {
    if (_selectedFilter == 'all') {
      return provider.leaves;
    }
    return provider.leaves.where((l) => l.status == _selectedFilter).toList();
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
        title: Text('Leave Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showApplyLeaveDialog(context),
          ),
        ],
      ),
      body: Consumer<HrProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.leaves.isEmpty) {
            return LoadingIndicator(message: 'Loading leaves...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadData,
            );
          }

          final filteredLeaves = _getFilteredLeaves(provider);

          return Column(
            children: [
              // Summary Cards
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Pending',
                        '${provider.pendingLeaves}',
                        Colors.orange,
                        Icons.pending,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Approved',
                        '${provider.approvedLeaves}',
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Rejected',
                        '${provider.rejectedLeaves}',
                        Colors.red,
                        Icons.cancel,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('Pending', 'pending', Colors.orange),
                    SizedBox(width: 8),
                    _buildFilterChip('Approved', 'approved', Colors.green),
                    SizedBox(width: 8),
                    _buildFilterChip('Rejected', 'rejected', Colors.red),
                    SizedBox(width: 8),
                    _buildFilterChip('All', 'all', Colors.blue),
                  ],
                ),
              ),

              // Leave Requests List
              Expanded(
                child: filteredLeaves.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.beach_access, size: 60, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No leave requests found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredLeaves.length,
                  itemBuilder: (context, index) {
                    final leave = filteredLeaves[index];
                    return _buildLeaveCard(leave, provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
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

  Widget _buildFilterChip(String label, String value, Color color) {
    bool isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'pending';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildLeaveCard(Leave leave, HrProvider provider) {
    Color statusColor = leave.status == 'pending'
        ? Colors.orange
        : leave.status == 'approved'
        ? Colors.green
        : Colors.red;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(
                    Icons.beach_access,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.employeeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        leave.leaveType,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    leave.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${leave.startDate.day}/${leave.startDate.month}/${leave.startDate.year} to ${leave.endDate.day}/${leave.endDate.month}/${leave.endDate.year} (${leave.days} days)',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.message, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    leave.reason,
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Applied: ${leave.appliedDate.day}/${leave.appliedDate.month}/${leave.appliedDate.year}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            if (leave.status == 'pending') ...[
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleLeaveAction(leave.id, 'approved', provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('Approve'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showRejectDialog(context, leave.id, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleLeaveAction(int leaveId, String status, HrProvider provider) async {
    final success = await provider.updateLeaveStatus(leaveId, status);
    if (mounted && success) {  // 🔥 mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave ${status} successfully'),
          backgroundColor: status == 'approved' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _showRejectDialog(BuildContext context, int leaveId, HrProvider provider) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Leave'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: 'Rejection Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              if (!context.mounted) return;  // 🔥 check

              final success = await provider.updateLeaveStatus(
                leaveId,
                'rejected',
                rejectionReason: reasonController.text,
              );

              if (success && context.mounted) {  // 🔥 check
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Leave rejected'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('REJECT'),
          ),
        ],
      ),
    );
  }

  void _showApplyLeaveDialog(BuildContext context) {
    String? selectedEmployeeId;
    String? selectedLeaveType;
    DateTime? startDate;
    DateTime? endDate;
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Apply Leave'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<HrProvider>(
                      builder: (context, provider, child) {
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Employee *',
                            border: OutlineInputBorder(),
                          ),
                          items: provider.employees.map((emp) {
                            return DropdownMenuItem(
                              value: emp.id.toString(),
                              child: Text(emp.fullName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedEmployeeId = value);
                          },
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Leave Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Annual Leave', 'Sick Leave', 'Emergency Leave', 'Maternity Leave']
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedLeaveType = value);
                      },
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => startDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(startDate == null
                                  ? 'Select date'
                                  : '${startDate!.day}/${startDate!.month}/${startDate!.year}'),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: startDate ?? DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => endDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(endDate == null
                                  ? 'Select date'
                                  : '${endDate!.day}/${endDate!.month}/${endDate!.year}'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'Reason *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedEmployeeId == null || selectedLeaveType == null ||
                        startDate == null || endDate == null ||
                        reasonController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    // Save provider reference before closing dialog
                    final hrProvider = Provider.of<HrProvider>(context, listen: false);

                    // Close dialog
                    Navigator.pop(dialogContext);

                    final leaveData = {
                      'employeeId': int.parse(selectedEmployeeId!),
                      'leaveType': selectedLeaveType,
                      'startDate': startDate!.toIso8601String().split('T')[0],
                      'endDate': endDate!.toIso8601String().split('T')[0],
                      'reason': reasonController.text,
                      'hotelId': _hotelId,
                    };

                    final success = await hrProvider.createLeave(leaveData);

                    if (success && mounted) {
                      await hrProvider.loadAllLeaves(_hotelId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Leave request submitted'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  child: Text('SUBMIT'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}