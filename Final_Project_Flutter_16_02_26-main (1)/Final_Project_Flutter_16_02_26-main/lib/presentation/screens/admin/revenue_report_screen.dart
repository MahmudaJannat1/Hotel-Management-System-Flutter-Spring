import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/report_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';
import 'package:hotel_management_app/data/models/revenue_report_model.dart';

class RevenueReportScreen extends StatefulWidget {
  final String reportType;
  final int hotelId;

  const RevenueReportScreen({
    Key? key,
    required this.reportType,
    required this.hotelId,
  }) : super(key: key);

  @override
  _RevenueReportScreenState createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  Future<void> _loadReport() async {
    if (!mounted) return;
    final provider = Provider.of<ReportProvider>(context, listen: false);

    switch (widget.reportType) {
      case 'standard':
        await provider.loadRevenueReport(widget.hotelId, _startDate, _endDate);
        break;
      case 'payment_method':
        await provider.loadRevenueReportByPaymentMethod(widget.hotelId, _startDate, _endDate);
        break;
      case 'room_type':
        await provider.loadRevenueReportByRoomType(widget.hotelId, _startDate, _endDate);
        break;
      case 'yearly':
        await provider.loadYearlyRevenueComparison(widget.hotelId, _selectedYear);
        break;
    }
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
      _loadReport();
    }
  }

  Future<void> _selectYear(BuildContext context) async {
    final int? picked = await showDialog(
      context: context,
      builder: (context) {
        int selectedYear = _selectedYear;
        return AlertDialog(
          title: Text('Select Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDate: DateTime(_selectedYear),
              selectedDate: DateTime(_selectedYear),
              onChanged: (DateTime dateTime) {
                selectedYear = dateTime.year;
                Navigator.pop(context, selectedYear);
              },
            ),
          ),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedYear = picked);
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: AppRoutes.adminReports),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_getTitle()),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.reportType != 'yearly')
            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () => _selectDateRange(context),
            ),
          if (widget.reportType == 'yearly')
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => _selectYear(context),
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return LoadingIndicator(message: 'Loading report...');
          }

          if (provider.error != null) {
            return ErrorWidgetWithRetry(
              message: provider.error!,
              onRetry: _loadReport,
            );
          }

          final report = provider.revenueReport;
          if (report == null) {
            return Center(child: Text('No data available'));
          }

          return RefreshIndicator(
            onRefresh: _loadReport,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeCard(report),
                  SizedBox(height: 20),
                  _buildSummaryCards(report),
                  SizedBox(height: 24),
                  _buildRevenueBreakdown(report),
                  SizedBox(height: 24),
                  _buildDailyRevenue(report),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getTitle() {
    switch (widget.reportType) {
      case 'standard':
        return 'Revenue Report';
      case 'payment_method':
        return 'Revenue by Payment';
      case 'room_type':
        return 'Revenue by Room Type';
      case 'yearly':
        return 'Yearly Comparison';
      default:
        return 'Revenue Report';
    }
  }

  Widget _buildDateRangeCard(RevenueReport report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Period',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  '${report.startDate.day}/${report.startDate.month}/${report.startDate.year} - '
                      '${report.endDate.day}/${report.endDate.month}/${report.endDate.year}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Generated: ${report.generatedAt}',
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(RevenueReport report) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildSummaryCard(
          'Total Revenue',
          CurrencyFormatter.format(report.totalRevenue),
          Icons.attach_money,
          Colors.green,
        ),
        _buildSummaryCard(
          'Room Revenue',
          CurrencyFormatter.format(report.totalRoomRevenue),
          Icons.hotel,
          Colors.blue,
        ),
        _buildSummaryCard(
          'F&B Revenue',
          CurrencyFormatter.format(report.totalFnbRevenue),
          Icons.restaurant,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Other Revenue',
          CurrencyFormatter.format(report.totalOtherRevenue),
          Icons.more_horiz,
          Colors.purple,
        ),
        _buildSummaryCard(
          'Avg. Daily Rate',
          CurrencyFormatter.format(report.averageDailyRate),
          Icons.trending_up,
          Colors.teal,
        ),
        _buildSummaryCard(
          'RevPAR',
          CurrencyFormatter.format(report.revenuePerAvailableRoom),
          Icons.analytics,
          Colors.indigo,
        ),
        _buildSummaryCard(
          'Total Bookings',
          '${report.totalBookings}',
          Icons.book_online,
          Colors.brown,
        ),
        _buildSummaryCard(
          'Cancelled',
          '${report.cancelledBookings}',
          Icons.cancel,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildRevenueBreakdown(RevenueReport report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildBreakdownItem(
              'Room Revenue',
              report.totalRoomRevenue,
              report.totalRevenue,
              Colors.blue,
            ),
            _buildBreakdownItem(
              'F&B Revenue',
              report.totalFnbRevenue,
              report.totalRevenue,
              Colors.orange,
            ),
            _buildBreakdownItem(
              'Other Revenue',
              report.totalOtherRevenue,
              report.totalRevenue,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, double amount, double total, Color color) {
    final percentage = total > 0 ? (amount / total * 100) : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(CurrencyFormatter.format(amount)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRevenue(RevenueReport report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Revenue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: report.dailyRevenue.length > 10 ? 10 : report.dailyRevenue.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final day = report.dailyRevenue[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${day.date.day}/${day.date.month}',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        CurrencyFormatter.format(day.totalRevenue),
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('${day.bookings} bkg'),
                    ),
                  ],
                );
              },
            ),
            if (report.dailyRevenue.length > 10)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Showing 10 of ${report.dailyRevenue.length} days',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}