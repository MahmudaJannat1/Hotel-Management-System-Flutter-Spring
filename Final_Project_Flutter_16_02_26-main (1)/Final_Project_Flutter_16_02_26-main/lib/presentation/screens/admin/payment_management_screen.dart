import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/payment_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';
import 'package:hotel_management_app/presentation/screens/admin/add_edit_payment_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/invoice_screen.dart';

import '../../../data/models/payment_model.dart';

class PaymentManagementScreen extends StatefulWidget {
  @override
  _PaymentManagementScreenState createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  final int _hotelId = 1;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final provider = Provider.of<PaymentProvider>(context, listen: false);
    await Future.wait([
      provider.loadAllPayments(_hotelId),
      provider.loadRevenueReport(_hotelId, _startDate, _endDate),
      provider.loadOutstandingAmount(_hotelId),
    ]);
  }

  List<Payment> _getFilteredPayments(List<Payment> payments) {
    List<Payment> filtered = List.from(payments);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.paymentNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.bookingNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.guestName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    switch (_selectedFilter) {
      case 'completed':
        filtered = filtered.where((p) => p.paymentStatus == 'COMPLETED').toList();
        break;
      case 'pending':
        filtered = filtered.where((p) => p.paymentStatus == 'PENDING').toList();
        break;
      case 'refunded':
        filtered = filtered.where((p) => p.paymentStatus == 'REFUNDED').toList();
        break;
    }

    return filtered;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminPayments),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        toolbarHeight: 90,
        title: Text('Payment Management'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditPaymentScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search payments...',
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
              Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('All', 'all', Icons.list),
                    _buildFilterChip('Completed', 'completed', Icons.check_circle, Colors.green),
                    _buildFilterChip('Pending', 'pending', Icons.pending, Colors.orange),
                    _buildFilterChip('Refunded', 'refunded', Icons.assignment_return, Colors.purple),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.payments.isEmpty) {
            return LoadingIndicator(message: 'Loading payments...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadData,
            );
          }

          final filteredPayments = _getFilteredPayments(provider.payments);

          return Column(
            children: [
              // Summary Cards
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Revenue',
                        CurrencyFormatter.format(provider.totalRevenue),
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Outstanding',
                        CurrencyFormatter.format(provider.outstandingAmount),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Completed',
                        '${provider.completedCount}',
                        Icons.check_circle,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // Payments List
              Expanded(
                child: filteredPayments.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, size: 60, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No payments found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredPayments.length,
                  itemBuilder: (context, index) {
                    final payment = filteredPayments[index];
                    return _buildPaymentCard(payment, provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, [Color? color]) {
    bool isSelected = _selectedFilter == value;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : (color ?? Colors.black54)),
            SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedFilter = selected ? value : 'all'),
        backgroundColor: Colors.grey[200],
        selectedColor: color ?? Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment, PaymentProvider provider) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          provider.selectPayment(payment);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditPaymentScreen(payment: payment),
            ),
          ).then((_) => _loadData());
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
                    radius: 20,
                    backgroundColor: payment.statusColor.withOpacity(0.1),
                    child: Icon(
                      payment.statusIcon,
                      color: payment.statusColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.paymentNumber,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Booking: ${payment.bookingNumber}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: payment.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      payment.paymentStatus,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: payment.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      payment.guestName,
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.hotel, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Rm ${payment.roomNumber}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        CurrencyFormatter.format(payment.amount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Method',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        payment.paymentMethod,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        '${payment.paymentDate.day}/${payment.paymentDate.month}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              if (payment.paymentStatus == 'COMPLETED') ...[
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // TextButton.icon(
                    //   onPressed: () {
                    //     provider.selectPayment(payment);
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => InvoiceScreen(payment: payment),
                    //       ),
                    //     );
                    //   },
                    //   icon: Icon(Icons.receipt, size: 16),
                    //   label: Text('View Invoice'),
                    //   style: TextButton.styleFrom(
                    //     foregroundColor: Colors.blue,
                    //     padding: EdgeInsets.zero,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}