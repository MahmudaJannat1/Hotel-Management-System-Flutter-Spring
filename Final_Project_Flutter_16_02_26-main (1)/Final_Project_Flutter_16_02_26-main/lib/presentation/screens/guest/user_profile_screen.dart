import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/presentation/screens/guest/guest_login_screen.dart';

import '../../../data/models/guest_user_model.dart';
import '../auth/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final provider = Provider.of<GuestProvider>(context, listen: false);
    final user = provider.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
      _passwordController.text = user.password;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<GuestProvider>(context, listen: false);
    final user = provider.currentUser!;
    print('👤 Current user ID: ${user.id}');  // এইটা দেখুন


    final updatedUser = GuestUser(
      id: user.id,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      password: user.password,
      isLoggedIn: true,
    );

    print('🔄 Updating to: ${updatedUser.toMap()}');

    final success = await provider.updateProfile(updatedUser);

    if (success && mounted) {
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('YES'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<GuestProvider>(context, listen: false);
      await provider.logout();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GuestLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuestProvider>(context);

    if (!provider.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Please login to view profile',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GuestLoginScreen()),
                );
              },
              child: Text('Login'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
          if (_isEditing)
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
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Guest logout
              final guestProvider = Provider.of<GuestProvider>(context, listen: false);
              await guestProvider.logout();

              // Navigate to Admin Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
            tooltip: 'Logout',
          ),


        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Avatar
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        provider.currentUser!.name.isNotEmpty
                            ? provider.currentUser!.name[0].toUpperCase()
                            : 'G',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      provider.currentUser!.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      provider.currentUser!.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Profile Form
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

                      // ✅ Name Field (Editable when _isEditing true)
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.person),
                          filled: _isEditing ? false : true,
                          fillColor: _isEditing ? null : Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),

                      // ✅ Email Field (Always disabled)
                      TextFormField(
                        controller: _emailController,
                        enabled: _isEditing,  // ✅ false থেকে true করুন
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.email),
                          filled: _isEditing ? false : true,
                          fillColor: _isEditing ? null : Colors.grey[100],
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),

                      // ✅ Phone Field (Editable when _isEditing true)
                      TextFormField(
                        controller: _phoneController,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.phone),
                          filled: _isEditing ? false : true,
                          fillColor: _isEditing ? null : Colors.grey[100],
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),

                      // ✅ Address Field (Editable when _isEditing true)
                      TextFormField(
                        controller: _addressController,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.location_on),
                          filled: _isEditing ? false : true,
                          fillColor: _isEditing ? null : Colors.grey[100],
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // ✅ Edit/Save/Cancel Buttons
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _loadUserData();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('CANCEL'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('SAVE'),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 12),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('LOGOUT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}