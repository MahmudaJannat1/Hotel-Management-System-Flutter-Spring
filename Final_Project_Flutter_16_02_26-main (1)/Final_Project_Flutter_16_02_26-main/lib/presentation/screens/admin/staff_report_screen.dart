import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/report_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';

import '../../../data/models/staff_report_model.dart';

class StaffReportScreen extends StatefulWidget {
  final String reportType;
  final int hotelId;
  final int? employeeId;
  final String? department;

  const StaffReportScreen({
    Key? key,
    required this.reportType,
    required this.hotelId,
    this.employeeId,
    this.department,
  }) : super(key: key);

  @override
  _StaffReportScreenState createState() => _StaffReportScreenState();
}

class _StaffReportScreenState extends State<StaffReportScreen> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  Future<void> _loadReport() async {
    if (!mounted) return;
    final provider = Provider.of<ReportProvider>(context, listen: false);

    switch (widget.reportType) {
      case 'all':
        await provider.loadStaffAttendanceReport(widget.hotelId, _startDate, _endDate);
        break;
      case 'department':
        if (widget.department != null) {
          await provider.loadDepartmentAttendanceReport(
            widget.hotelId,
            widget.department!,
            _startDate,
            _endDate,
          );
        }
        break;
      case 'individual':
        if (widget.employeeId != null) {
          await provider.loadIndividualStaffReport(
            widget.employeeId!,
            _startDate,
            _endDate,
          );
        }
        break;
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminReports),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_getTitle()),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return LoadingIndicator(message: 'Loading report...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadReport,
            );
          }

          final report = provider.staffReport;
          if (report == null) {
            return Center(child: Text('No data available'));
          }

          if (report.totalStaff == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No attendance data found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'for selected period',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadReport,
                    child: Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadReport,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeCard(report),
                  SizedBox(height: 20),
                  _buildSummaryCards(report),
                  SizedBox(height: 24),
                  _buildDepartmentStats(report),
                  SizedBox(height: 24),
                  _buildDailyAttendance(report),
                  SizedBox(height: 24),
                  _buildStaffList(report),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getTitle() {
    switch (widget.reportType) {
      case 'all':
        return 'Staff Attendance';
      case 'department':
        return '${widget.department} Attendance';
      case 'individual':
        return 'Employee Attendance';
      default:
        return 'Staff Report';
    }
  }

  Widget _buildDateRangeCard(StaffAttendanceReport report) {

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Period',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  '${report.startDate.day}/${report.startDate.month}/${report.startDate.year} - '
                      '${report.endDate.day}/${report.endDate.month}/${report.endDate.year}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Generated: ${report.generatedAt}',
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(StaffAttendanceReport report) {
    String _formatPercentage(double value) {
      if (value.isNaN || value.isInfinite) {
        return '0%';
      }
      return '${value.toStringAsFixed(1)}%';
    }

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildSummaryCard(
          'Total Staff',
          '${report.totalStaff}',
          Icons.people,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Avg. Present',
          '${report.averageDailyPresent}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildSummaryCard(
          'Avg. Absent',
          '${report.averageDailyAbsent}',
          Icons.cancel,
          Colors.red,
        ),
        _buildSummaryCard(
          'Avg. Leave',
          '${report.averageDailyLeave}',
          Icons.beach_access,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Attendance %',
          _formatPercentage(report.attendancePercentage),
          Icons.percent,
          Colors.purple,
        ),
      ],
    );
  }



  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentStats(StaffAttendanceReport report) {
    if (report.departmentStats.isEmpty) return SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...report.departmentStats.entries.map((entry) {
              final stats = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stats.department,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${stats.present}/${stats.totalStaff} present',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: stats.attendancePercentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stats.attendancePercentage > 80 ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${stats.attendancePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyAttendance(StaffAttendanceReport report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Attendance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: report.dailyAttendance.length > 10 ? 10 : report.dailyAttendance.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final day = report.dailyAttendance[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${day.date.day}/${day.date.month}',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('P: ${day.present}', style: TextStyle(color: Colors.green)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('A: ${day.absent}', style: TextStyle(color: Colors.red)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('L: ${day.onLeave}', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                );
              },
            ),
            if (report.dailyAttendance.length > 10)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Showing 10 of ${report.dailyAttendance.length} days',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffList(StaffAttendanceReport report) {
    if (report.staffAttendance.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No staff attendance records',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: report.staffAttendance.length > 10 ? 10 : report.staffAttendance.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final staff = report.staffAttendance[index];
                return ListTile(
                  dense: true,
                  title: Text(staff.employeeName),
                  subtitle: Text('${staff.department} • ${staff.position}'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${staff.presentDays}/${staff.totalDays} days',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${staff.attendancePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: staff.attendancePercentage > 80 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}