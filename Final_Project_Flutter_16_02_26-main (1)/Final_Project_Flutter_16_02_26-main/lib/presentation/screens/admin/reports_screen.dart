import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/report_provider.dart';
import 'package:hotel_management_app/providers/hr_provider.dart';
import 'package:hotel_management_app/providers/inventory_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/presentation/screens/admin/occupancy_report_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/revenue_report_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/staff_report_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/inventory_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final int _hotelId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    final hrProvider = Provider.of<HrProvider>(context, listen: false);
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    await Future.wait([
      hrProvider.loadAllEmployees(_hotelId),
      hrProvider.loadAllDepartments(_hotelId),
      inventoryProvider.loadAllItems(_hotelId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminReports),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
          },
        ),
        title: Text('Reports'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Occupancy Reports'),
            SizedBox(height: 12),
            _buildReportCard(
              icon: Icons.hotel,
              title: 'Occupancy Report',
              subtitle: 'View room occupancy by date range',
              color: Colors.blue,
              onTap: () => _navigateToOccupancyReport(context, 'standard'),
            ),
            _buildReportCard(
              icon: Icons.pie_chart,
              title: 'Occupancy by Room Type',
              subtitle: 'Breakdown of occupancy by room category',
              color: Colors.purple,
              onTap: () => _navigateToOccupancyReport(context, 'room_type'),
            ),
            _buildReportCard(
              icon: Icons.calendar_month,
              title: 'Monthly Occupancy',
              subtitle: 'Monthly occupancy summary for a year',
              color: Colors.teal,
              onTap: () => _navigateToOccupancyReport(context, 'monthly'),
            ),

            SizedBox(height: 24),
            _buildSectionTitle('Revenue Reports'),
            SizedBox(height: 12),
            _buildReportCard(
              icon: Icons.attach_money,
              title: 'Revenue Report',
              subtitle: 'View revenue by date range',
              color: Colors.green,
              onTap: () => _navigateToRevenueReport(context, 'standard'),
            ),
            _buildReportCard(
              icon: Icons.payment,
              title: 'Revenue by Payment Method',
              subtitle: 'Revenue breakdown by payment type',
              color: Colors.orange,
              onTap: () => _navigateToRevenueReport(context, 'payment_method'),
            ),
            _buildReportCard(
              icon: Icons.king_bed,
              title: 'Revenue by Room Type',
              subtitle: 'Revenue breakdown by room category',
              color: Colors.red,
              onTap: () => _navigateToRevenueReport(context, 'room_type'),
            ),
            _buildReportCard(
              icon: Icons.compare_arrows,
              title: 'Yearly Comparison',
              subtitle: 'Compare revenue year over year',
              color: Colors.indigo,
              onTap: () => _navigateToRevenueReport(context, 'yearly'),
            ),

            SizedBox(height: 24),
            _buildSectionTitle('Staff Reports'),
            SizedBox(height: 12),
            _buildReportCard(
              icon: Icons.people,
              title: 'Staff Attendance',
              subtitle: 'Attendance report for all staff',
              color: Colors.orange,
              onTap: () => _navigateToStaffReport(context, 'all'),
            ),
            _buildReportCard(
              icon: Icons.business,
              title: 'Department Attendance',
              subtitle: 'Attendance by department',
              color: Colors.teal,
              onTap: () => _showDepartmentDialog(context),
            ),
            _buildReportCard(
              icon: Icons.person,
              title: 'Individual Staff',
              subtitle: 'Attendance for specific employee',
              color: Colors.cyan,
              onTap: () => _showEmployeeDialog(context),
            ),

            SizedBox(height: 24),
            _buildSectionTitle('Inventory Reports'),
            SizedBox(height: 12),
            _buildReportCard(
              icon: Icons.inventory,
              title: 'Inventory Summary',
              subtitle: 'Current stock levels and values',
              color: Colors.brown,
              onTap: () => _navigateToInventoryReport(context, 'standard'),
            ),
            _buildReportCard(
              icon: Icons.category,
              title: 'Category Report',
              subtitle: 'Inventory by category',
              color: Colors.deepOrange,
              onTap: () => _showCategoryDialog(context),
            ),
            _buildReportCard(
              icon: Icons.history,
              title: 'Transaction History',
              subtitle: 'Stock movement transactions',
              color: Colors.pink,
              onTap: () => _navigateToInventoryReport(context, 'transactions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue[800],
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  void _navigateToOccupancyReport(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OccupancyReportScreen(
          reportType: type,
          hotelId: _hotelId,
        ),
      ),
    );
  }

  void _navigateToRevenueReport(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RevenueReportScreen(
          reportType: type,
          hotelId: _hotelId,
        ),
      ),
    );
  }

  void _navigateToStaffReport(BuildContext context, String type, {int? employeeId, String? department}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffReportScreen(
          reportType: type,
          hotelId: _hotelId,
          employeeId: employeeId,
          department: department,
        ),
      ),
    );
  }

  void _navigateToInventoryReport(BuildContext context, String type, {String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryReportScreen(
          reportType: type,
          hotelId: _hotelId,
          category: category,
        ),
      ),
    );
  }

  // ========== Department Selection Dialog ==========

  void _showDepartmentDialog(BuildContext context) {
    final hrProvider = Provider.of<HrProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Department'),
              content: Container(
                width: double.maxFinite,
                child: hrProvider.departments.isEmpty
                    ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No departments found'),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: hrProvider.departments.length,
                  itemBuilder: (context, index) {
                    final dept = hrProvider.departments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        child: Icon(Icons.business, color: Colors.teal),
                      ),
                      title: Text(dept.name),
                      subtitle: Text('${dept.totalEmployees} employees'),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _navigateToStaffReport(
                          context,
                          'department',
                          department: dept.name,
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('CANCEL'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ========== Employee Selection Dialog ==========

  void _showEmployeeDialog(BuildContext context) {
    final hrProvider = Provider.of<HrProvider>(context, listen: false);
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredEmployees = searchQuery.isEmpty
                ? hrProvider.employees
                : hrProvider.searchEmployees(searchQuery);

            return AlertDialog(
              title: Text('Select Employee'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search employees...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: filteredEmployees.isEmpty
                          ? Center(child: Text('No employees found'))
                          : ListView.builder(
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final emp = filteredEmployees[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.cyan.withOpacity(0.1),
                              child: Text(
                                emp.fullName.isNotEmpty ? emp.fullName[0] : '?',
                                style: TextStyle(color: Colors.cyan),
                              ),
                            ),
                            title: Text(emp.fullName),
                            subtitle: Text('${emp.position} • ${emp.employeeId}'),
                            onTap: () {
                              Navigator.pop(dialogContext);
                              _navigateToStaffReport(
                                context,
                                'individual',
                                employeeId: emp.id,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('CANCEL'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ========== Category Selection Dialog ==========

  void _showCategoryDialog(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    // Get unique categories from inventory items
    final categories = inventoryProvider.items
        .map((item) => item.category)
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Category'),
              content: Container(
                width: double.maxFinite,
                child: categories.isEmpty
                    ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No categories found'),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final itemCount = inventoryProvider.items
                        .where((item) => item.category == category)
                        .length;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepOrange.withOpacity(0.1),
                        child: Icon(Icons.category, color: Colors.deepOrange),
                      ),
                      title: Text(category),
                      subtitle: Text('$itemCount items'),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _navigateToInventoryReport(
                          context,
                          'category',
                          category: category,
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('CANCEL'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}