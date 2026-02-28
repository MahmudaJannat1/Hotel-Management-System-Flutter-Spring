import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/hr_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/presentation/screens/admin/add_edit_employee_screen.dart';
import '../../../data/models/employee_model.dart';

class EmployeeListScreen extends StatefulWidget {
  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final int _hotelId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmployees();
    });
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;
    final hrProvider = Provider.of<HrProvider>(context, listen: false);
    await hrProvider.loadAllEmployees(_hotelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminHr),
      appBar: AppBar(
        leading: IconButton(  // 🔥 Back Button
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // HR Dashboard এ ফিরে যাবে
          },
        ),
        title: Text('Employee List'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEmployees,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditEmployeeScreen(),
                ),
              ).then((_) {
                if (mounted) _loadEmployees();
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: Consumer<HrProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.employees.isEmpty) {
            return LoadingIndicator(message: 'Loading employees...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadEmployees,
            );
          }

          final filteredEmployees = provider.searchEmployees(_searchQuery);

          if (filteredEmployees.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadEmployees,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                return _buildEmployeeCard(employee, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee, HrProvider provider) {
    Color statusColor = employee.employmentStatus == 'ACTIVE'
        ? Colors.green
        : employee.employmentStatus == 'ON_LEAVE'
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          provider.selectEmployee(employee);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditEmployeeScreen(employee: employee),
            ),
          ).then((_) {
            if (mounted) _loadEmployees();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      employee.fullName.isNotEmpty ? employee.fullName[0] : '?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          employee.position,
                          style: TextStyle(
                            fontSize: 14,
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
                      employee.employmentStatus,
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
                  Icon(Icons.badge, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(employee.employeeId, style: TextStyle(fontSize: 12)),
                  SizedBox(width: 16),
                  Icon(Icons.email, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      employee.email,
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(employee.phone, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          provider.selectEmployee(employee);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditEmployeeScreen(employee: employee),
                            ),
                          ).then((_) {
                            if (mounted) _loadEmployees();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEmployee(context, employee.id, provider),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteEmployee(BuildContext context, int id, HrProvider provider) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Employee'),
        content: Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.deleteEmployee(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No employees found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try different search term'
                : 'Click + to add new employee',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}