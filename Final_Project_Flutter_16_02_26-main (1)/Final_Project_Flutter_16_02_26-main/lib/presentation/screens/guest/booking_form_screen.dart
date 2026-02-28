import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/data/models/guest_room_model.dart';
import 'package:hotel_management_app/data/models/guest_booking_model.dart';
import 'package:hotel_management_app/presentation/screens/guest/booking_confirmation_screen.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';
import 'package:hotel_management_app/core/utils/validators.dart';

import '../auth/login_screen.dart';
import 'card_payment_screen.dart';
import 'guest_login_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final GuestRoom room;
  final DateTime? preSelectedCheckIn;
  final DateTime? preSelectedCheckOut;
  final int? preSelectedGuests;

  const BookingFormScreen({
    Key? key,
    required this.room,
    this.preSelectedCheckIn,
    this.preSelectedCheckOut,
    this.preSelectedGuests,
  }) : super(key: key);

  @override
  _BookingFormScreenState createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 2;
  String _selectedPaymentMethod = 'pay_at_hotel';
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _saveInfo = false;

  final List<String> _paymentMethods = [
    'pay_at_hotel',
    'card',
    'mobile_banking',
  ];

  @override
  void initState() {
    super.initState();

    _checkInDate = widget.preSelectedCheckIn ?? DateTime.now();
    _checkOutDate = widget.preSelectedCheckOut ??
        DateTime.now().add(Duration(days: 1));
    _numberOfGuests = widget.preSelectedGuests ?? 2;

    // ✅ Auto-fill guest info from currentUser
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedInfo();
      _fillGuestInfoFromCurrentUser(); // এই মেঠড কল করুন
    });
  }

// ✅ নতুন মেঠড যোগ করুন
  void _fillGuestInfoFromCurrentUser() {
    final provider = Provider.of<GuestProvider>(context, listen: false);
    final user = provider.currentUser;

    if (user != null) {
      print('✅ Auto-filling form for: ${user.name}');
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
    }
  }


  Future<void> _loadSavedInfo() async {
    // TODO: Load saved guest info from SharedPreferences
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  int get _numberOfNights {
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double get _totalAmount {
    return widget.room.price * _numberOfNights;
  }

  double get _advancePayment {
    if (_selectedPaymentMethod == 'pay_at_hotel') return 0;
    return _totalAmount * 0.2; // 20% advance for online payment
  }

  double get _dueAmount {
    return _totalAmount - _advancePayment;
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate! : _checkOutDate!,
      firstDate: isCheckIn ? DateTime.now() : _checkInDate!,
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate!.add(Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

// booking_form_screen.dart এ _submitBooking() মেথড আপডেট করুন

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Generate booking number
    final bookingNumber = 'BK${DateTime.now().millisecondsSinceEpoch}${widget.room.id}';

    print('🚀 Creating booking: $bookingNumber');
    print('Room: ${widget.room.roomNumber}');
    print('Guest: ${_nameController.text}');

    final booking = GuestBooking(
      id: 0,
      bookingNumber: bookingNumber,
      roomId: widget.room.id,
      roomNumber: widget.room.roomNumber,
      roomType: widget.room.roomType,
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
      numberOfGuests: _numberOfGuests,
      status: 'confirmed',
      totalAmount: _totalAmount,
      advancePayment: _advancePayment,
      dueAmount: _dueAmount,
      paymentMethod: _selectedPaymentMethod,
      specialRequests: _specialRequestsController.text.isNotEmpty
          ? _specialRequestsController.text
          : null,
      guestName: _nameController.text,
      guestEmail: _emailController.text,
      guestPhone: _phoneController.text,
      createdAt: DateTime.now(),
      hotelId: widget.room.hotelId,
    );

    final provider = Provider.of<GuestProvider>(context, listen: false);
    final success = await provider.createBooking(booking);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // ✅ Booking成功后 immediately reload bookings
      if (provider.currentUser != null) {
        await provider.loadBookingsByGuest(provider.currentUser!.email);
        print('✅ Bookings reloaded: ${provider.bookings.length}');
      }

      if (_saveInfo) {
        // TODO: Save to SharedPreferences
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            booking: booking,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to create booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Your Stay'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                  // BookingFormScreen.dart - Room Summary Card এর ইমেজ অংশ ঠিক করুন

                  ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.room.images.isNotEmpty
                      ? Image.asset(  // ✅ Image.network থেকে Image.asset করুন
                    widget.room.images.first,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Image error: $error');
                      return Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  )
                      : Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.hotel),
                  ),
                ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.room.roomType} • Room ${widget.room.roomNumber}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Floor ${widget.room.floor} • Max ${widget.room.maxOccupancy} guests',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(widget.room.price),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Booking Dates Card
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
                        'Booking Dates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Check-in',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: Icon(Icons.login),
                                ),
                                child: Text(
                                  '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Check-out',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: Icon(Icons.logout),
                                ),
                                child: Text(
                                  '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$_numberOfNights nights',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Guest Information Card
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
                        'Guest Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!Validators.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),

                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),

                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Number of Guests'),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline),
                                      onPressed: _numberOfGuests > 1
                                          ? () => setState(() => _numberOfGuests--)
                                          : null,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$_numberOfGuests',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline),
                                      onPressed: _numberOfGuests < widget.room.maxOccupancy
                                          ? () => setState(() => _numberOfGuests++)
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      CheckboxListTile(
                        title: Text('Save this information for next time'),
                        value: _saveInfo,
                        onChanged: (value) {
                          setState(() => _saveInfo = value!);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Payment Method Card
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
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      // BookingFormScreen.dart - payment method selection অংশ আপডেট করুন

                      ..._paymentMethods.map((method) {
                        return RadioListTile<String>(
                          title: Text(_getPaymentMethodName(method)),
                          subtitle: Text(_getPaymentMethodDescription(method)),
                          value: method,
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) async {
                            setState(() => _selectedPaymentMethod = value!);

                            // যদি credit card সিলেক্ট করে, তাহলে payment screen খুলুন
                            if (value == 'card') {
                              final paymentSuccess = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CardPaymentScreen(
                                    amount: _advancePayment,
                                    onPaymentSuccess: (payment) {
                                      print('✅ Payment successful for card: ${payment.maskedCardNumber}');
                                      // এখানে payment info save করতে পারেন যদি চান
                                    },
                                  ),
                                ),
                              );

                              // যদি payment fails বা cancel করে, তাহলে 'pay_at_hotel' এ revert করুন
                              if (paymentSuccess != true) {
                                setState(() => _selectedPaymentMethod = 'pay_at_hotel');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Payment cancelled. Please select another payment method.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
                          },
                          secondary: Icon(_getPaymentMethodIcon(method)),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Special Requests Card
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
                        'Special Requests (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      TextFormField(
                        controller: _specialRequestsController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Late check-in, extra pillows, room preference...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Price Summary Card
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
                        'Price Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      _buildPriceRow(
                        'Room Price (${_numberOfNights} nights)',
                        CurrencyFormatter.format(_totalAmount),
                      ),
                      if (_advancePayment > 0) ...[
                        Divider(),
                        _buildPriceRow(
                          'Advance Payment (20%)',
                          CurrencyFormatter.format(_advancePayment),
                          color: Colors.green,
                        ),
                        _buildPriceRow(
                          'Due at Hotel',
                          CurrencyFormatter.format(_dueAmount),
                          isBold: true,
                        ),
                      ],
                      Divider(thickness: 2),
                      _buildPriceRow(
                        'Total',
                        CurrencyFormatter.format(_totalAmount),
                        isBold: true,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Terms and Conditions
              CheckboxListTile(
                title: Text(
                  'I agree to the terms and conditions and cancellation policy',
                  style: TextStyle(fontSize: 13),
                ),
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() => _agreeToTerms = value!);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'CONFIRM BOOKING',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'You won\'t be charged yet',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount,
      {bool isBold = false, double fontSize = 14, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize - 2,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: fontSize,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'pay_at_hotel':
        return 'Pay at Hotel';
      case 'card':
        return 'Credit/Debit Card';
      case 'mobile_banking':
        return 'Mobile Banking';
      default:
        return method;
    }
  }

  String _getPaymentMethodDescription(String method) {
    switch (method) {
      case 'pay_at_hotel':
        return 'Pay when you check-in (No advance payment)';
      case 'card':
        return 'Secure online payment (20% advance required)';
      case 'mobile_banking':
        return 'bKash, Nagad, Rocket (20% advance required)';
      default:
        return '';
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'pay_at_hotel':
        return Icons.hotel;
      case 'card':
        return Icons.credit_card;
      case 'mobile_banking':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }
}