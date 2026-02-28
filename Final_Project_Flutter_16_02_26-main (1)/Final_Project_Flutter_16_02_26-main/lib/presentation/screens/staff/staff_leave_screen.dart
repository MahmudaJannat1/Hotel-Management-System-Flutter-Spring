// lib/presentation/screens/staff/staff_leave_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/presentation/widgets/staff_drawer.dart';

import '../../../data/models/staff_leave_balance.dart';
import '../../../data/models/staff_leave_model.dart';
import '../../../data/models/staff_user_model.dart';


class StaffLeaveScreen extends StatefulWidget {
  @override
  _StaffLeaveScreenState createState() => _StaffLeaveScreenState();
}

class _StaffLeaveScreenState extends State<StaffLeaveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<StaffLeave> _leaves = [];
  StaffLeaveBalance? _balance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaveData();
    });
  }


  Future<void> _loadLeaveData() async {
    final provider = Provider.of<StaffProvider>(context, listen: false);
    if (provider.currentUser != null) {
      _leaves = await provider.getStaffLeaves(provider.currentUser!.id);
      _balance = await provider.getLeaveBalance(provider.currentUser!.id);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  void switchToHistoryTab() {
    if (_tabController.index != 1) {
      _tabController.animateTo(1); // Switch to history tab (index 1)
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Apply Leave'),
            Tab(text: 'Leave History'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLeaveData,
          ),
        ],
      ),
      drawer: StaffDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplyLeaveTab(context, user),
          _buildLeaveHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildApplyLeaveTab(BuildContext context, StaffUser? user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Leave Balance Cards
          if (_balance != null) ...[
            Text(
              'Leave Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildBalanceCard('Sick Leave', _balance!.sickLeaveUsed, _balance!.sickLeaveTotal, Colors.red),
                _buildBalanceCard('Casual Leave', _balance!.casualLeaveUsed, _balance!.casualLeaveTotal, Colors.green),
                _buildBalanceCard('Annual Leave', _balance!.annualLeaveUsed, _balance!.annualLeaveTotal, Colors.blue),
                _buildBalanceCard('Emergency', _balance!.emergencyLeaveUsed, _balance!.emergencyLeaveTotal, Colors.orange),
              ],
            ),
            SizedBox(height: 20),
          ],

          // Leave Application Form
          LeaveApplicationForm(
            staffId: user?.id ?? 0,
            staffName: user?.name ?? '',
            onLeaveApplied: _loadLeaveData,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, int used, int total, Color color) {
    double percentage = used / total;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            SizedBox(height: 8),
            Text(
              '$used/$total',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveHistoryTab() {
    if (_leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No leave applications yet'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _leaves.length,
      itemBuilder: (context, index) {
        final leave = _leaves[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: leave.statusColor.withOpacity(0.1),
              child: Icon(leave.statusIcon, color: leave.statusColor),
            ),
            title: Text(
              '${leave.leaveType} Leave',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${leave.startDate.day}/${leave.startDate.month} - ${leave.endDate.day}/${leave.endDate.month} (${leave.totalDays} days)',
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: leave.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                leave.status,
                style: TextStyle(
                  color: leave.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Reason:', leave.reason),
                    _buildDetailRow('Applied On:', leave.appliedOn?.split('T')[0] ?? ''),
                    if (leave.status == 'Approved' && leave.approvedBy != null)
                      _buildDetailRow('Approved By:', leave.approvedBy!),
                    if (leave.status == 'Rejected' && leave.rejectionReason != null)
                      _buildDetailRow('Rejection Reason:', leave.rejectionReason!),
                  ],
                ),
              ),
              if (leave.status == 'Pending')
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Cancel Leave'),
                              content: Text('Are you sure you want to cancel this leave request?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('NO'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('YES'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final provider = Provider.of<StaffProvider>(context, listen: false);
                            final success = await provider.cancelLeave(leave.id);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Leave cancelled successfully'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              _loadLeaveData();
                            }
                          }
                        },
                        child: Text(
                          'CANCEL REQUEST',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Leave Application Form Widget
class LeaveApplicationForm extends StatefulWidget {
  final int staffId;
  final String staffName;
  final VoidCallback onLeaveApplied;

  const LeaveApplicationForm({
    Key? key,
    required this.staffId,
    required this.staffName,
    required this.onLeaveApplied,
  }) : super(key: key);

  @override
  _LeaveApplicationFormState createState() => _LeaveApplicationFormState();
}

class _LeaveApplicationFormState extends State<LeaveApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedLeaveType = 'Sick';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 1));
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  final List<String> _leaveTypes = ['Sick', 'Casual', 'Annual', 'Emergency'];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  int get _totalDays => _endDate.difference(_startDate).inDays + 1;

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final leave = StaffLeave(
      id: 0,
      staffId: widget.staffId,
      staffName: widget.staffName,
      leaveType: _selectedLeaveType,
      startDate: _startDate,
      endDate: _endDate,
      totalDays: _totalDays,
      reason: _reasonController.text,
      status: 'Pending',
      appliedOn: DateTime.now().toIso8601String(),
    );

    final provider = Provider.of<StaffProvider>(context, listen: false);
    final success = await provider.applyLeave(leave);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave application submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _formKey.currentState!.reset();
      _reasonController.clear();

      // Reload data
      widget.onLeaveApplied();

      // ✅ Find parent state and switch tab
      final parentState = context.findAncestorStateOfType<_StaffLeaveScreenState>();
      if (parentState != null) {
        // Small delay to ensure data is loaded
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            parentState.switchToHistoryTab();
          }
        });
      } else {
        print('⚠️ Could not find parent StaffLeaveScreenState');
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to submit leave'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apply for Leave',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Leave Type
              DropdownButtonFormField<String>(
                value: _selectedLeaveType,
                decoration: InputDecoration(
                  labelText: 'Leave Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _leaveTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedLeaveType = value!),
              ),
              SizedBox(height: 16),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Total Days: $_totalDays',
                style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a reason';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitLeave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('APPLY FOR LEAVE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}