import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/report_provider.dart';
import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
import 'package:hotel_management_app/presentation/widgets/loading_indicator.dart';
import 'package:hotel_management_app/presentation/widgets/error_widget.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/core/utils/currency_formatter.dart';

import '../../../data/models/inventory_report_model.dart';

class InventoryReportScreen extends StatefulWidget {
  final String reportType;
  final int hotelId;
  final String? category;

  const InventoryReportScreen({
    Key? key,
    required this.reportType,
    required this.hotelId,
    this.category,
  }) : super(key: key);

  @override
  _InventoryReportScreenState createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

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
        await provider.loadInventoryReport(widget.hotelId);
        break;
      case 'category':
        if (widget.category != null) {
          await provider.loadInventoryReportByCategory(widget.hotelId, widget.category!);
        }
        break;
      case 'transactions':
        await provider.loadInventoryTransactionReport(widget.hotelId, _startDate, _endDate);
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
          if (widget.reportType == 'transactions')
            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () => _selectDateRange(context),
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

          final report = provider.inventoryReport;
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
                  _buildDateCard(report),
                  SizedBox(height: 20),
                  _buildSummaryCards(report),
                  SizedBox(height: 24),
                  _buildCategoryStats(report),
                  SizedBox(height: 24),
                  _buildLowStockItems(report),
                  SizedBox(height: 24),
                  if (widget.reportType == 'transactions')
                    _buildTransactions(report),
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
        return 'Inventory Report';
      case 'category':
        return '${widget.category} Inventory';
      case 'transactions':
        return 'Stock Transactions';
      default:
        return 'Inventory Report';
    }
  }

  Widget _buildDateCard(InventoryReport report) {
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
                  'As of Date',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  '${report.asOfDate.day}/${report.asOfDate.month}/${report.asOfDate.year}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Generated: ${report.generatedAt}',
                style: TextStyle(fontSize: 11, color: Colors.brown),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(InventoryReport report) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildSummaryCard(
          'Total Items',
          '${report.totalItems}',
          Icons.inventory,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Total Value',
          CurrencyFormatter.format(report.totalInventoryValue),
          Icons.attach_money,
          Colors.green,
        ),
        _buildSummaryCard(
          'Low Stock',
          '${report.lowStockItems}',
          Icons.warning,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Out of Stock',
          '${report.outOfStockItems}',
          Icons.error,
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

  Widget _buildCategoryStats(InventoryReport report) {
    if (report.categoryStats.isEmpty) return SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...report.categoryStats.entries.map((entry) {
              final stats = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stats.category,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${stats.itemCount} items',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Qty: ${stats.totalQuantity}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Value: ${CurrencyFormatter.format(stats.totalValue)}',
                            style: TextStyle(fontSize: 11, color: Colors.green),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Low: ${stats.lowStockCount}',
                            style: TextStyle(
                              fontSize: 11,
                              color: stats.lowStockCount > 0 ? Colors.orange : Colors.grey,
                            ),
                          ),
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

  Widget _buildLowStockItems(InventoryReport report) {
    if (report.lowStockItemsList.isEmpty) return SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Low Stock Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: report.lowStockItemsList.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final item = report.lowStockItemsList[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: item.status == 'CRITICAL'
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    child: Icon(
                      Icons.warning,
                      size: 16,
                      color: item.status == 'CRITICAL' ? Colors.red : Colors.orange,
                    ),
                  ),
                  title: Text(item.itemName),
                  subtitle: Text('${item.category} • ${item.supplier ?? 'No supplier'}'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.currentQuantity} ${item.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: item.status == 'CRITICAL' ? Colors.red : Colors.orange,
                        ),
                      ),
                      Text(
                        'Reorder: ${item.reorderLevel}',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions(InventoryReport report) {
    if (report.recentTransactions.isEmpty) return SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: report.recentTransactions.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final txn = report.recentTransactions[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: txn.transactionType == 'PURCHASE'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    child: Icon(
                      txn.transactionType == 'PURCHASE' ? Icons.add : Icons.remove,
                      size: 16,
                      color: txn.transactionType == 'PURCHASE' ? Colors.green : Colors.blue,
                    ),
                  ),
                  title: Text(txn.itemName),
                  subtitle: Text(
                    '${txn.transactionType} • ${txn.supplier ?? '-'}',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${txn.quantity} × ${CurrencyFormatter.format(txn.unitPrice)}',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        CurrencyFormatter.format(txn.totalPrice),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}