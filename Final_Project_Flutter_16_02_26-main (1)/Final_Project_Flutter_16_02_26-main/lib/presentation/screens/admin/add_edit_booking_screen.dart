import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/booking_provider.dart';
import 'package:hotel_management_app/providers/room_provider.dart';
import 'package:hotel_management_app/data/models/booking_model.dart';
import 'package:hotel_management_app/data/models/guest_model.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

import '../../../data/repositories/guest_repository.dart';

class AddEditBookingScreen extends StatefulWidget {
  final int? bookingId;
  final bool isViewOnly;

  const AddEditBookingScreen({
    Key? key,
    this.bookingId,
    this.isViewOnly = false,
  }) : super(key: key);

  @override
  _AddEditBookingScreenState createState() => _AddEditBookingScreenState();
}


class _AddEditBookingScreenState extends State<AddEditBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final GuestRepository _guestRepo = GuestRepository();
  List<Guest> _guests = [];
  bool _isLoadingGuests = false;

  // Controllers
  late TextEditingController _guestNameController;
  late TextEditingController _guestPhoneController;
  late TextEditingController _guestEmailController;
  late TextEditingController _roomNumberController;
  late TextEditingController _roomTypeController;
  late TextEditingController _numberOfGuestsController;
  late TextEditingController _totalAmountController;
  late TextEditingController _advancePaymentController;
  late TextEditingController _dueAmountController;
  late TextEditingController _specialRequestsController;

  // Variables
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String _selectedStatus = 'pending';
  String _selectedPaymentMethod = 'cash';
  int? _selectedRoomId;
  int? _selectedGuestId;

  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _statuses = ['pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled'];
  final List<String> _paymentMethods = ['cash', 'card', 'online', 'bank_transfer'];


  @override
  void initState() {
    super.initState();

    _initializeControllers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGuests();
      _loadData();
    });
  }

  Future<void> _loadGuests() async {
    setState(() => _isLoadingGuests = true);
    try {
      _guests = await _guestRepo.getAllGuests();
    } catch (e) {
      print('Error loading guests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load guests'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoadingGuests = false);
    }
  }


  void _initializeControllers() {
    _guestNameController = TextEditingController();
    _guestPhoneController = TextEditingController();
    _guestEmailController = TextEditingController();
    _roomNumberController = TextEditingController();
    _roomTypeController = TextEditingController();
    _numberOfGuestsController = TextEditingController();
    _totalAmountController = TextEditingController();
    _advancePaymentController = TextEditingController();
    _dueAmountController = TextEditingController();
    _specialRequestsController = TextEditingController();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load rooms and guests for dropdowns
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    await Future.wait([
      roomProvider.loadAllRooms(),
    ]);

    // Load booking if editing
    if (widget.bookingId != null) {
      _isEditing = true;
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.loadBookingById(widget.bookingId!);
      final booking = bookingProvider.selectedBooking;

      if (booking != null) {
        _populateBookingData(booking);
      }
    }

    setState(() => _isLoading = false);
  }

  void _populateBookingData(Booking booking) {
    print('🔵 Populating booking: ${booking.id}');

    _guestNameController.text = booking.guestName;
    _roomNumberController.text = booking.roomNumber;
    _roomTypeController.text = booking.roomType;
    _numberOfGuestsController.text = booking.numberOfGuests.toString();
    _totalAmountController.text = booking.totalAmount.toString();
    _advancePaymentController.text = booking.advancePayment.toString();
    _dueAmountController.text = booking.dueAmount.toString();
    _specialRequestsController.text = booking.specialRequests ?? '';

    _checkInDate = booking.checkInDate;
    _checkOutDate = booking.checkOutDate;
    _selectedStatus = booking.status.toLowerCase();
    _selectedPaymentMethod = booking.paymentMethod;
    _selectedRoomId = booking.roomId;
    _selectedGuestId = booking.guestId;

    print('✅ GuestID: $_selectedGuestId, RoomID: $_selectedRoomId, Status: $_selectedStatus');
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate!.add(Duration(days: 1));
          }
        } else {
          if (_checkInDate != null && picked.isBefore(_checkInDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Check-out must be after check-in')),
            );
          } else {
            _checkOutDate = picked;
          }
        }
      });
    }
  }

  void _calculateDueAmount() {
    double total = double.tryParse(_totalAmountController.text) ?? 0;
    double advance = double.tryParse(_advancePaymentController.text) ?? 0;
    _dueAmountController.text = (total - advance).toStringAsFixed(2);
  }

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_checkInDate == null || _checkOutDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select dates'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);

      final bookingData = {
        'guestId': _selectedGuestId,
        'roomId': _selectedRoomId,
        'checkInDate': _checkInDate!.toIso8601String().split('T')[0],
        'checkOutDate': _checkOutDate!.toIso8601String().split('T')[0],
        'numberOfGuests': int.parse(_numberOfGuestsController.text),
        'status': _selectedStatus,
        'totalAmount': double.parse(_totalAmountController.text),
        'advancePayment': double.parse(_advancePaymentController.text),
        'dueAmount': double.parse(_dueAmountController.text),
        'paymentMethod': _selectedPaymentMethod.toLowerCase(),
        'specialRequests': _specialRequestsController.text,
      };

      print('========== UPDATING BOOKING ==========');
      print('Booking ID: ${widget.bookingId}');
      print('Data: $bookingData');
      print('======================================');


      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bool success;

      if (_isEditing) {
        success = await bookingProvider.updateBooking(widget.bookingId!, bookingData);
      } else {
        success = await bookingProvider.createBooking(bookingData);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Booking updated' : 'Booking created'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(bookingProvider.error ?? 'Failed to save'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isViewOnly = widget.isViewOnly;
    final roomProvider = Provider.of<RoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? (isViewOnly ? 'Booking Details' : 'Edit Booking')
            : 'New Booking'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isViewOnly && _isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteBooking(context),
            ),
        ],
      ),
      drawer: CommonDrawer(currentRoute: AppRoutes.adminBookings),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guest Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guest Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      // Guest Dropdown
                      DropdownButtonFormField<int>(
                        value: _guests.any((g) => g.id == _selectedGuestId) ? _selectedGuestId : null,
                        decoration: InputDecoration(
                          labelText: 'Select Guest *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _guests.map((guest) {
                          return DropdownMenuItem(
                            value: guest.id,
                            child: Text(guest.fullName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGuestId = value;
                            final guest = _guests.firstWhere((g) => g.id == value);
                            _guestNameController.text = guest.fullName;
                            _guestPhoneController.text = guest.phone ?? '';
                            _guestEmailController.text = guest.email ?? '';
                          });
                        },
                        validator: (value) => value == null ? 'Select guest' : null,
                        hint: Text('Select a guest'),  // ✅ hint যোগ করুন
                      ),

                      if (_selectedGuestId != null) ...[
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _guestNameController,
                          enabled: !isViewOnly,
                          decoration: InputDecoration(
                            labelText: 'Guest Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _guestPhoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                enabled: false,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _guestEmailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                enabled: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Room Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Room Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      // Room Dropdown
                      DropdownButtonFormField<int>(
                        value: roomProvider.rooms.any((r) => r.id == _selectedRoomId) ? _selectedRoomId : null,
                        decoration: InputDecoration(
                          labelText: 'Select Room *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.hotel),
                        ),
                        items: roomProvider.rooms.map((room) {
                          return DropdownMenuItem(
                            value: room.id,
                            child: Text('${room.roomNumber} - ${room.roomType}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRoomId = value;
                            final room = roomProvider.rooms.firstWhere((r) => r.id == value);
                            _roomNumberController.text = room.roomNumber;
                            _roomTypeController.text = room.roomType;
                          });
                        },
                        validator: (value) => value == null ? 'Select room' : null,
                      ),


                      if (_selectedRoomId != null) ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _roomNumberController,
                                decoration: InputDecoration(
                                  labelText: 'Room Number',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                enabled: false,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _roomTypeController,
                                decoration: InputDecoration(
                                  labelText: 'Room Type',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                enabled: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Booking Dates Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Dates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: isViewOnly ? null : () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Check-in Date *',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _checkInDate == null
                                      ? 'Select date'
                                      : '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: isViewOnly ? null : () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Check-out Date *',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _checkOutDate == null
                                      ? 'Select date'
                                      : '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      TextFormField(
                        controller: _numberOfGuestsController,
                        decoration: InputDecoration(
                          labelText: 'Number of Guests *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !isViewOnly,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (int.tryParse(value) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Payment Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _totalAmountController,
                        decoration: InputDecoration(
                          labelText: 'Total Amount *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !isViewOnly,
                        onChanged: (_) => _calculateDueAmount(),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null) return 'Invalid amount';
                          return null;
                        },
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _advancePaymentController,
                              decoration: InputDecoration(
                                labelText: 'Advance Payment',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.money),
                              ),
                              keyboardType: TextInputType.number,
                              enabled: !isViewOnly,
                              onChanged: (_) => _calculateDueAmount(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _dueAmountController,
                              decoration: InputDecoration(
                                labelText: 'Due Amount',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: Icon(Icons.money_off),
                              ),
                              enabled: false,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _statuses.contains(_selectedStatus) ? _selectedStatus : null,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: _statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedStatus = value!),
                        hint: Text('Select Status'),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Additional Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Additional Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      if (_isEditing && !isViewOnly)
                        DropdownButtonFormField<String>(
                          value: _statuses.contains(_selectedStatus) ? _selectedStatus : null,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: _statuses.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedStatus = value!),
                          hint: Text('Select Status'),
                        ),

                      if (_isEditing && !isViewOnly)
                        SizedBox(height: 16),

                      TextFormField(
                        controller: _specialRequestsController,
                        decoration: InputDecoration(
                          labelText: 'Special Requests',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        enabled: !isViewOnly,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Action Buttons
              if (!isViewOnly)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey),
                        ),
                        child: Text('CANCEL'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveBooking,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue[800],
                        ),
                        child: Text(_isEditing ? 'UPDATE' : 'CREATE'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteBooking(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Booking'),
        content: Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final success = await bookingProvider.deleteBooking(widget.bookingId!);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context, true);
        }
      }
    }
  }
}