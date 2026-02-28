import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/report_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';
import 'package:hotel_management_app/data/models/occupancy_report_model.dart';

class OccupancyReportScreen extends StatefulWidget {
  final String reportType;
  final int hotelId;

  const OccupancyReportScreen({
    Key? key,
    required this.reportType,
    required this.hotelId,
  }) : super(key: key);

  @override
  _OccupancyReportScreenState createState() => _OccupancyReportScreenState();
}

class _OccupancyReportScreenState extends State<OccupancyReportScreen> {
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
        await provider.loadOccupancyReport(widget.hotelId, _startDate, _endDate);
        break;
      case 'room_type':
        await provider.loadOccupancyReportByRoomType(widget.hotelId, _startDate, _endDate);
        break;
      case 'monthly':
        await provider.loadMonthlyOccupancyReport(widget.hotelId, _selectedYear);
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
          if (widget.reportType != 'monthly')
            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () => _selectDateRange(context),
            ),
          if (widget.reportType == 'monthly')
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

          final report = provider.occupancyReport;
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
                  _buildDailyOccupancy(report),
                  SizedBox(height: 24),
                  _buildRoomTypeStats(report),
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
        return 'Occupancy Report';
      case 'room_type':
        return 'Occupancy by Room Type';
      case 'monthly':
        return 'Monthly Occupancy';
      default:
        return 'Occupancy Report';
    }
  }

  Widget _buildDateRangeCard(OccupancyReport report) {
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
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Generated: ${report.generatedAt}',
                style: TextStyle(fontSize: 11, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(OccupancyReport report) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildSummaryCard(
          'Total Rooms',
          '${report.totalRooms}',
          Icons.hotel,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Occupied',
          '${report.totalOccupiedRooms}',
          Icons.person,
          Colors.green,
        ),
        _buildSummaryCard(
          'Available',
          '${report.totalAvailableRooms}',
          Icons.check_circle,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Maintenance',
          '${report.totalMaintenanceRooms}',
          Icons.build,
          Colors.red,
        ),
        _buildSummaryCard(
          'Avg. Occupancy',
          '${report.averageOccupancyRate.toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.purple,
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildDailyOccupancy(OccupancyReport report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Occupancy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: report.dailyOccupancy.length > 10 ? 10 : report.dailyOccupancy.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final day = report.dailyOccupancy[index];
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
                      flex: 1,
                      child: Text('Occ: ${day.occupiedRooms}'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('Avail: ${day.availableRooms}'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${day.occupancyRate.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: day.occupancyRate > 70 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (report.dailyOccupancy.length > 10)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Showing 10 of ${report.dailyOccupancy.length} days',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTypeStats(OccupancyReport report) {
    if (report.roomTypeStats.isEmpty) return SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Type Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...report.roomTypeStats.entries.map((entry) {
              final stats = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            stats.roomTypeName,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${stats.occupiedRooms}/${stats.totalRooms} rooms',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: stats.occupancyRate / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stats.occupancyRate > 70 ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${stats.occupancyRate.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Avg Rate: ${CurrencyFormatter.format(stats.averageRate)}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                        Text(
                          'Revenue: ${CurrencyFormatter.format(stats.totalRevenue)}',
                          style: TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}