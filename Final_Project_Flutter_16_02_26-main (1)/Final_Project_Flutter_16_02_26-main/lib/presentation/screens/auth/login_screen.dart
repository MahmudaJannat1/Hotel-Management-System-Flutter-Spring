import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/auth_provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart'; // Add this import
import 'package:hotel_management_app/presentation/screens/staff/staff_home_screen.dart'; // Add this import
import 'package:hotel_management_app/presentation/screens/guest/guest_home_screen.dart'; // Import guest home

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Admin controllers
  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  // Staff controllers
  final _staffEmailController = TextEditingController();
  final _staffPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    _staffEmailController.dispose();
    _staffPasswordController.dispose();
    super.dispose();
  }

  // Admin login handler
  void _handleAdminLogin() async {
    if (_adminUsernameController.text.isEmpty || _adminPasswordController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _adminUsernameController.text.trim(),
      _adminPasswordController.text,
    );

    if (success && mounted) {
      // Navigate to admin home (you need to define your admin home screen)
      // Assuming you have an AdminHomeScreen, replace with your actual route
      Navigator.pushReplacementNamed(context, '/admin/home');
    } else {
      _showSnackBar(authProvider.error ?? 'Login failed', Colors.red);
    }
  }

  // Staff login handler
  void _handleStaffLogin() async {
    if (_staffEmailController.text.isEmpty || _staffPasswordController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    final success = await staffProvider.login(
      _staffEmailController.text.trim(),
      _staffPasswordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StaffHomeScreen()),
      );
    } else {
      _showSnackBar(staffProvider.error ?? 'Login failed', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.hotel, size: 80, color: Theme.of(context).primaryColor),
                  SizedBox(height: 10),
                  Text(
                    'Hotel Management System',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(30),
              ),
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.blue[800],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.blue[800],
                tabs: [
                  Tab(text: 'Admin Login'),
                  Tab(text: 'Staff Login'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Admin Login Form
                  _buildAdminLoginForm(),
                  // Staff Login Form
                  _buildStaffLoginForm(),
                ],
              ),
            ),

            // Guest mode link at bottom (optional, can be moved inside each form or kept common)
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GuestHomeScreen()),
                  );
                },
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.admin_panel_settings, size: 60, color: Colors.blue[800]),
              SizedBox(height: 20),
              TextFormField(
                controller: _adminUsernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _adminPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 24),
              authProvider.isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handleAdminLogin,
                child: Text('Admin Login', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaffLoginForm() {
    return Consumer<StaffProvider>(
      builder: (context, staffProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.badge, size: 60, color: Colors.blue[800]),
              SizedBox(height: 20),

              // Demo users hint
              // Container(
              //   padding: EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: Colors.blue[50],
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Column(
              //     children: [
              //       Text('Staff Users:', style: TextStyle(fontWeight: FontWeight.bold)),
              //       SizedBox(height: 4),
              //       Text('man@g.com / 123456'),
              //       Text('recep@g.com / 123456'),
              //       Text('house@g.com / 123456'),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 20),

              TextFormField(
                controller: _staffEmailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _staffPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 24),
              staffProvider.isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handleStaffLogin,
                child: Text('Staff Login', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}