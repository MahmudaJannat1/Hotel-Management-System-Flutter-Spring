// lib/presentation/screens/guest/guest_login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/data/models/guest_room_model.dart';
import 'package:hotel_management_app/data/models/guest_user_model.dart';
import 'package:hotel_management_app/presentation/screens/guest/booking_form_screen.dart';

class GuestLoginScreen extends StatefulWidget {
  final GuestRoom? redirectRoom;

  const GuestLoginScreen({Key? key, this.redirectRoom}) : super(key: key);

  @override
  _GuestLoginScreenState createState() => _GuestLoginScreenState();
}

class _GuestLoginScreenState extends State<GuestLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();  // ✅ password field
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isRegistering = false;
  bool _obscurePassword = true;  // ✅ password hide/show

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validation
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email', Colors.red);
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter your password', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<GuestProvider>(context, listen: false);
    final success = await provider.login(
      _emailController.text,
      _passwordController.text,  // ✅ password পাঠান
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar('Login successful!', Colors.green);

      if (widget.redirectRoom != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingFormScreen(room: widget.redirectRoom!),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    } else {
      _showSnackBar('Login failed. Invalid email or password.', Colors.red);
    }
  }

  Future<void> _handleRegister() async {
    // Validation
    if (_nameController.text.isEmpty) {
      _showSnackBar('Please enter your name', Colors.red);
      return;
    }
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email', Colors.red);
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter your password', Colors.red);
      return;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', Colors.red);
      return;
    }
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter your phone number', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final user = GuestUser(
      id: 0,
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,  // ✅ password পাঠান
      phone: _phoneController.text,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      isLoggedIn: false,
    );

    final provider = Provider.of<GuestProvider>(context, listen: false);
    final success = await provider.register(user);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar('Registration successful!', Colors.green);

      if (widget.redirectRoom != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingFormScreen(room: widget.redirectRoom!),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    } else {
      _showSnackBar('Registration failed. Email may already exist.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Create Account' : 'Guest Login'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.blue[800],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Registration fields
            if (_isRegistering) ...[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
            ],

            // Email field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            // ✅ Password field (common for both login and register)
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isRegistering ? _handleRegister : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isRegistering ? 'REGISTER' : 'LOGIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Toggle between login and register
            TextButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                  // Clear fields when switching
                  _emailController.clear();
                  _passwordController.clear();
                  _nameController.clear();
                  _phoneController.clear();
                  _addressController.clear();
                });
              },
              child: Text(
                _isRegistering
                    ? 'Already have an account? Login'
                    : 'New user? Create an account',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 14,
                ),
              ),
            ),

            // if (!_isRegistering) ...[
            //   SizedBox(height: 16),
            //   // Demo user hint
            //   Container(
            //     padding: EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: Colors.grey[100],
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Column(
            //       children: [
            //         Text(
            //           'Demo Users:',
            //           style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             color: Colors.grey[700],
            //           ),
            //         ),
            //         // SizedBox(height: 4),
            //         // Text(
            //         //   'Email: akash@guest.com',
            //         //   style: TextStyle(color: Colors.blue[800]),
            //         // ),
            //         // Text(
            //         //   'Password: 123456',
            //         //   style: TextStyle(color: Colors.blue[800]),
            //         // ),
            //       ],
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}