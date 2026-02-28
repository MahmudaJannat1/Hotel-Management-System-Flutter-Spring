import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/user_provider.dart';
import 'package:hotel_management_app/providers/auth_provider.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/presentation/screens/admin/add_edit_user_screen.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/common_drawer.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedFilter = 'all'; // all, admin, manager, staff, active, inactive
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadAllUsers();
  }



  List<User> _getFilteredUsers(List<User> users) {
    List<User> filtered = List.from(users);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.username.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply role filter
    switch (_selectedFilter) {
      case 'admin':
        filtered = filtered.where((u) => u.role == 'ADMIN').toList();
        break;
      case 'manager':
        filtered = filtered.where((u) => u.role == 'MANAGER').toList();
        break;
      case 'staff':
        filtered = filtered.where((u) => u.role == 'STAFF').toList();
        break;
      case 'guest':
        filtered = filtered.where((u) => u.role == 'GUEST').toList();
        break;
      case 'active':
        filtered = filtered.where((u) => u.isActive).toList();
        break;
      case 'inactive':
        filtered = filtered.where((u) => !u.isActive).toList();
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminUsers),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        toolbarHeight: 90,
        title: Text('User Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditUserScreen(),
                ),
              ).then((_) => _loadUsers());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Filter Chips
              Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('All', 'all', Icons.people),
                    _buildFilterChip('Admin', 'admin', Icons.admin_panel_settings),
                    _buildFilterChip('Manager', 'manager', Icons.manage_accounts),
                    _buildFilterChip('Staff', 'staff', Icons.person),
                    _buildFilterChip('Guest', 'guest', Icons.person_outline),
                    _buildFilterChip('Active', 'active', Icons.check_circle),
                    _buildFilterChip('Inactive', 'inactive', Icons.cancel),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditUserScreen()),
          ).then((_) => _loadUsers());
        },
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.users.isEmpty) {
            return LoadingIndicator(message: 'Loading users...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadUsers,
            );
          }

          final filteredUsers = _getFilteredUsers(provider.users);

          if (filteredUsers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadUsers,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return _buildUserCard(user, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    bool isSelected = _selectedFilter == value;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black54),
            SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildUserCard(User user, UserProvider provider) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          provider.selectUser(user);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditUserScreen(user: user),
            ),
          ).then((_) => _loadUsers());
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
                    backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0] : '?',
                      style: TextStyle(
                        color: _getRoleColor(user.role),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          user.email,
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
                      color: _getRoleColor(user.role).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(user.role),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '@${user.username}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16),
                  if (user.phone != null) ...[
                    Icon(Icons.phone, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      user.phone!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: user.isActive ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        user.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          color: user.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 18, color: Colors.blue),
                        onPressed: () {
                          provider.selectUser(user);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditUserScreen(user: user),
                            ),
                          ).then((_) => _loadUsers());
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          user.isActive ? Icons.block : Icons.check_circle,
                          size: 18,
                          color: user.isActive ? Colors.orange : Colors.green,
                        ),
                        onPressed: () async {
                          final confirmed = await _showConfirmDialog(
                            context,
                            user.isActive ? 'Deactivate' : 'Activate',
                            'Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} ${user.fullName}?',
                          );
                          if (confirmed) {
                            await provider.toggleUserStatus(user.id);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await _showConfirmDialog(
                            context,
                            'Delete',
                            'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
                          );
                          if (confirmed) {
                            await provider.deleteUser(user.id);
                          }
                        },
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN': return Colors.red;
      case 'MANAGER': return Colors.blue;
      case 'STAFF': return Colors.green;
      case 'GUEST': return Colors.orange;
      default: return Colors.grey;
    }
  }

// _showConfirmDialog method টা নিশ্চিত করুন
  Future<bool> _showConfirmDialog(BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              title == 'Delete Room' ? 'DELETE' : 'CONFIRM',
              style: TextStyle(color: title == 'Delete Room' ? Colors.red : Colors.blue),
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Try changing your search or filter'
                : 'Click + to add a new user',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}