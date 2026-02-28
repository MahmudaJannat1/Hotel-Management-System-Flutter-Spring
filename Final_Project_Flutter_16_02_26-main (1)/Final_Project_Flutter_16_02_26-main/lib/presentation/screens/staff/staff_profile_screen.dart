import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/presentation/widgets/staff_drawer.dart';

import '../../../data/models/staff_user_model.dart';

class StaffProfileScreen extends StatefulWidget {
  @override
  _StaffProfileScreenState createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final provider = Provider.of<StaffProvider>(context, listen: false);
    final user = provider.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<StaffProvider>(context, listen: false);
    final user = provider.currentUser!;

    final updatedUser = StaffUser(
      id: user.id,
      name: _nameController.text,
      email: user.email, // email অপরিবর্তিত
      password: user.password,
      role: user.role,
      phone: _phoneController.text,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      isLoggedIn: true,
    );

    final success = await provider.updateProfile(updatedUser);

    setState(() => _isLoading = false);

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    // TODO: Implement password change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password change coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _loadUserData();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveProfile,
            ),
          ],
        ],
      ),
      drawer: StaffDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            user?.name[0] ?? 'S',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue[800],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      user?.role ?? '',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Personal Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Name
                    _buildInfoField(
                      label: 'Full Name',
                      value: user?.name ?? '',
                      icon: Icons.person,
                      controller: _nameController,
                      isEditing: _isEditing,
                    ),
                    SizedBox(height: 12),

                    // Email (non-editable)
                    _buildInfoField(
                      label: 'Email',
                      value: user?.email ?? '',
                      icon: Icons.email,
                      isEditing: false,
                    ),
                    SizedBox(height: 12),

                    // Phone
                    _buildInfoField(
                      label: 'Phone',
                      value: user?.phone ?? '',
                      icon: Icons.phone,
                      controller: _phoneController,
                      isEditing: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12),

                    // Address
                    _buildInfoField(
                      label: 'Address',
                      value: user?.address ?? 'Not provided',
                      icon: Icons.location_on,
                      controller: _addressController,
                      isEditing: _isEditing,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Account Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildInfoRow(
                      'Staff ID',
                      'STF${user?.id.toString().padLeft(3, '0')}',
                      Icons.badge,
                    ),
                    _buildInfoRow(
                      'Role',
                      user?.role ?? '',
                      Icons.work,
                    ),
                    _buildInfoRow(
                      'Member Since',
                      'January 2024',
                      Icons.calendar_today,
                    ),

                    SizedBox(height: 16),

                    // Change Password Button
                    OutlinedButton(
                      onPressed: _changePassword,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[800],
                        side: BorderSide(color: Colors.blue[800]!),
                        minimumSize: Size(double.infinity, 45),
                      ),
                      child: Text('Change Password'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required IconData icon,
    TextEditingController? controller,
    bool isEditing = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        SizedBox(height: 4),
        isEditing && controller != null
            ? TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        )
            : Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}