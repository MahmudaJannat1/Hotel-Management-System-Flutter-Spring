import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/payment_provider.dart';
import 'package:hotel_management_app/providers/booking_provider.dart';
import 'package:hotel_management_app/data/models/payment_model.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';

class AddEditPaymentScreen extends StatefulWidget {
  final Payment? payment;

  const AddEditPaymentScreen({Key? key, this.payment}) : super(key: key);

  @override
  _AddEditPaymentScreenState createState() => _AddEditPaymentScreenState();
}

class _AddEditPaymentScreenState extends State<AddEditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final int _hotelId = 1;

  late TextEditingController _amountController;
  late TextEditingController _transactionIdController;
  late TextEditingController _cardLastFourController;
  late TextEditingController _bankNameController;
  late TextEditingController _chequeNumberController;
  late TextEditingController _mobileAccountNoController;
  late TextEditingController _referenceController;
  late TextEditingController _notesController;
  late TextEditingController _receivedByController;

  int? _selectedBookingId;
  String _selectedPaymentMethod = 'CASH';
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _paymentMethods = [
    'CASH',
    'CARD',
    'BANK_TRANSFER',
    'MOBILE_BANKING',
    'ONLINE'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _isEditing = widget.payment != null;

    // 🔥 post frame callback-এ load করুন
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  void _initializeControllers() {
    _amountController = TextEditingController(
      text: widget.payment?.amount.toString() ?? '',
    );
    _transactionIdController = TextEditingController(
      text: widget.payment?.transactionId ?? '',
    );
    _cardLastFourController = TextEditingController(
      text: widget.payment?.cardLastFour ?? '',
    );
    _bankNameController = TextEditingController(
      text: widget.payment?.bankName ?? '',
    );
    _chequeNumberController = TextEditingController(
      text: widget.payment?.chequeNumber ?? '',
    );
    _mobileAccountNoController = TextEditingController(
      text: widget.payment?.mobileAccountNo ?? '',
    );
    _referenceController = TextEditingController(
      text: widget.payment?.reference ?? '',
    );
    _notesController = TextEditingController(
      text: widget.payment?.notes ?? '',
    );
    _receivedByController = TextEditingController(
      text: widget.payment?.receivedBy ?? '',
    );

    if (widget.payment != null) {
      _selectedPaymentMethod = widget.payment!.paymentMethod;
      _selectedBookingId = widget.payment!.bookingId;
    }
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    await bookingProvider.loadAllBookings();
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBookingId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a booking'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);

      final paymentData = {
        'bookingId': _selectedBookingId,
        'amount': double.parse(_amountController.text),
        'paymentMethod': _selectedPaymentMethod,
        'transactionId': _transactionIdController.text.isNotEmpty
            ? _transactionIdController.text
            : null,
        'cardLastFour': _cardLastFourController.text.isNotEmpty
            ? _cardLastFourController.text
            : null,
        'bankName': _bankNameController.text.isNotEmpty
            ? _bankNameController.text
            : null,
        'chequeNumber': _chequeNumberController.text.isNotEmpty
            ? _chequeNumberController.text
            : null,
        'mobileBankingProvider': _selectedPaymentMethod == 'MOBILE_BANKING'
            ? _mobileAccountNoController.text
            : null,
        'mobileAccountNo': _selectedPaymentMethod == 'MOBILE_BANKING'
            ? _mobileAccountNoController.text
            : null,
        'reference': _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
        'notes': _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
        'receivedBy': _receivedByController.text.isNotEmpty
            ? _receivedByController.text
            : null,
        'hotelId': _hotelId,
      };

      final provider = Provider.of<PaymentProvider>(context, listen: false);
      bool success;

      if (_isEditing) {
        success = await provider.refundPayment(
          widget.payment!.id,
          'Manual refund',
        );
      } else {
        success = await provider.processPayment(paymentData);

        // 🔥 এখানে invoice generate করুন
        if (success) {
          final invoiceData = {
            'bookingId': _selectedBookingId,
            'dueDate': DateTime.now().add(Duration(days: 7)).toIso8601String().split('T')[0],
            'roomCharges': double.parse(_amountController.text),
            'taxRate': 15.0,
            'generatedBy': 'Admin',
          };

          await provider.generateInvoice(invoiceData);
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Payment refunded' : 'Payment processed and invoice generated'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to save'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminPayments),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        toolbarHeight: 90,
        title: Text(_isEditing ? 'Refund Payment' : 'Process Payment'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
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
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: _selectedBookingId,
                        decoration: InputDecoration(
                          labelText: 'Select Booking *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.book_online),
                        ),
                        items: bookingProvider.bookings.map((booking) {
                          return DropdownMenuItem(
                            value: booking.id,
                            child: Text(
                              '${booking.bookingNumber} - ${booking.guestName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: _isEditing
                            ? null
                            : (value) => setState(() => _selectedBookingId = value),
                        validator: (value) =>
                        value == null ? 'Select booking' : null,
                      ),

                      SizedBox(height: 12),

                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !_isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null) return 'Invalid amount';
                          return null;
                        },
                      ),

                      SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        decoration: InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: _paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method.replaceAll('_', ' ')),
                          );
                        }).toList(),
                        onChanged: _isEditing
                            ? null
                            : (value) => setState(() => _selectedPaymentMethod = value!),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              if (_selectedPaymentMethod == 'CARD') ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),

                        TextFormField(
                          controller: _cardLastFourController,
                          decoration: InputDecoration(
                            labelText: 'Card Last 4 Digits',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: Icon(Icons.credit_card),
                          ),
                          enabled: !_isEditing,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_selectedPaymentMethod == 'BANK_TRANSFER') ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bank Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),

                        TextFormField(
                          controller: _bankNameController,
                          decoration: InputDecoration(
                            labelText: 'Bank Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: Icon(Icons.account_balance),
                          ),
                          enabled: !_isEditing,
                        ),

                        SizedBox(height: 12),

                        TextFormField(
                          controller: _chequeNumberController,
                          decoration: InputDecoration(
                            labelText: 'Cheque Number',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          enabled: !_isEditing,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_selectedPaymentMethod == 'MOBILE_BANKING') ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mobile Banking Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),

                        TextFormField(
                          controller: _mobileAccountNoController,
                          decoration: InputDecoration(
                            labelText: 'Account Number',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: Icon(Icons.phone_android),
                          ),
                          enabled: !_isEditing,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _transactionIdController,
                        decoration: InputDecoration(
                          labelText: 'Transaction ID',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.receipt),
                        ),
                        enabled: !_isEditing,
                      ),

                      SizedBox(height: 12),

                      TextFormField(
                        controller: _referenceController,
                        decoration: InputDecoration(
                          labelText: 'Reference',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.tag),
                        ),
                        enabled: !_isEditing,
                      ),

                      SizedBox(height: 12),

                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                        enabled: !_isEditing,
                      ),

                      SizedBox(height: 12),

                      TextFormField(
                        controller: _receivedByController,
                        decoration: InputDecoration(
                          labelText: 'Received By',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.person),
                        ),
                        enabled: !_isEditing,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

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
                      onPressed: _savePayment,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _isEditing ? Colors.red : Colors.blue[800],
                      ),
                      child: Text(_isEditing ? 'REFUND' : 'PROCESS'),
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

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _cardLastFourController.dispose();
    _bankNameController.dispose();
    _chequeNumberController.dispose();
    _mobileAccountNoController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    _receivedByController.dispose();
    super.dispose();
  }
}